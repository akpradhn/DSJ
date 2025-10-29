import SwiftUI
import CoreData

struct PatientDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showQuickGivenSheet: Dose?
    @State private var showAddDose = false
    @State private var vaccineSearchText = ""
    @State private var vaccineDB: VaccineDB? = VaccineDBLoader.load()
    @State private var hasBackfilled: Bool = false
    @State private var didRunBackfillTask: Bool = false

    @State private var confirmDeletePatient = false
    @State private var doseToDelete: Dose?

    let patient: Patient

    // Gracefully handle potentially missing DOB values from older data
    private var safeDOB: Date { (patient.value(forKey: "dob") as? Date) ?? Date() }

    // Standard age groups (non-optional vaccines)
    private let standardAgeBuckets: [(label: String, weeks: Int)] = [
        ("At Birth", 0), ("6 Weeks", 6), ("10 Weeks", 10), ("14 Weeks", 14),
        ("6 Months", 26), ("7 Months", 30), ("6–9 Months", 35), ("9 Months", 39),
        ("12 Months", 52), ("13 Months", 56), ("15 Months", 65), ("16–18 Months", 69),
        ("18–19 Months", 78), ("2–3 Years", 104), ("3–4 Years", 156), ("4–5 Years", 208),
        ("4–6 Years", 260), ("9–14 Years", 468)
    ]
    // Optional vaccines age groups per card
    private let optionalAgeBuckets: [(label: String, weeks: Int)] = [
        ("9 Month", 39), ("12 Month", 52), ("13 Month", 56), ("After 9 Month", 39), ("After 2 years", 104), ("Any Age", 0)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                actions
                // Vaccine search within patient schedule
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search vaccines...", text: $vaccineSearchText)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                schedule
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddDose = true } label: { Image(systemName: "plus").bold() }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                PatientFormView(patient: patient, onSaved: { _ in showingEdit = false }, onCancel: { showingEdit = false })
                    .environment(\.managedObjectContext, context)
            }
        }
        .sheet(item: $showQuickGivenSheet) { dose in
            QuickGivenSheet(dose: dose)
        }
        .sheet(isPresented: $showAddDose) {
            NavigationStack {
                AddDoseView(patient: patient)
                    .environment(\.managedObjectContext, context)
            }
        }
        .task(id: patient.objectID) {
            if didRunBackfillTask { return }
            // Run backfill at most once per patient (persisted across launches)
            let key = "backfilled_patient_\(patient.objectID.uriRepresentation().absoluteString)"
            // Suppress backfill briefly right after a restore snapshot
            let restoreDate = BackupService.lastRestoreDate
            let shouldSuppressBackfill: Bool = {
                if let r = restoreDate { return Date().timeIntervalSince(r) < 600 } // 10 minutes window
                return false
            }()
            if !UserDefaults.standard.bool(forKey: key) && !shouldSuppressBackfill {
                await backfillMissingDosesIfNeeded()
                UserDefaults.standard.set(true, forKey: key)
                hasBackfilled = true
            }
            // One-time global cleanup for duplicate vaccine masters and doses
            if !UserDefaults.standard.bool(forKey: "vaccines_dedup_done") {
                await cleanupDuplicateVaccinesAndDoses()
                UserDefaults.standard.set(true, forKey: "vaccines_dedup_done")
            }
            didRunBackfillTask = true
        }
        .alert("Delete Patient?", isPresented: $confirmDeletePatient) {
            Button("Delete", role: .destructive) { performDeletePatient() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will remove the patient and all doses.") }
        .alert("Delete Dose?", isPresented: Binding(get: { doseToDelete != nil }, set: { if !$0 { doseToDelete = nil } })) {
            Button("Delete", role: .destructive) { if let d = doseToDelete { performDeleteDose(d) } }
            Button("Cancel", role: .cancel) { doseToDelete = nil }
        } message: { Text("This will delete the selected dose.") }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.15)).frame(width: 84, height: 84)
                    Image(systemName: "person.fill").foregroundColor(.blue).font(.system(size: 36, weight: .semibold))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.displayName).font(.system(size: 28, weight: .bold))
                    HStack(spacing: 8) {
                        Text(patient.gender ?? "-").foregroundColor(.secondary)
                        Text("•").foregroundColor(.secondary)
                        Text("Born \(DateHelpers.formatDate(safeDOB))").foregroundColor(.secondary)
                    }
                }
            }

            HStack {
                metric(icon: "calendar", title: "Weight", value: Formatters.grams(Int(patient.birthWeightGrams)))
                Divider()
                metric(icon: "ruler", title: "Length", value: "\(patient.lengthCm) cm")
                Divider()
                metric(icon: "circle.lefthalf.filled", title: "Head Circ.", value: String(format: "%.0f cm", patient.headCircumferenceCm))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
        }
    }

    private func metric(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Image(systemName: icon).foregroundColor(.secondary)
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        HStack(spacing: 16) {
            Button(action: { showingEdit = true }) {
                Label("Edit", systemImage: "pencil").padding().frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: { confirmDeletePatient = true }) {
                Label("Delete", systemImage: "trash").padding().frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var schedule: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended Vaccines").font(.title3.bold())
            ForEach(VaccineDBLoader.normalOrder, id: \.self) { key in
                let items = dosesFor(labelKey: key, optional: false)
                if !items.isEmpty {
                    Section {
                        ForEach(items, id: \.objectID) { dose in
                            DoseRowView(dose: dose)
                                .swipeActions(edge: .leading) {
                                    Button { showQuickGivenSheet = dose } label: { Label("Mark Given", systemImage: "checkmark.circle") }
                                        .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { doseToDelete = dose } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    } header: {
                        Text(keyToHeader(key)).font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                    }
                }
            }

            // Optional vaccines
            if VaccineDBLoader.optionalOrder.contains(where: { !dosesFor(labelKey: $0, optional: true).isEmpty }) {
                Text("Optional Vaccines").font(.title3.bold()).padding(.top, 12)
                ForEach(VaccineDBLoader.optionalOrder, id: \.self) { key in
                    let items = dosesFor(labelKey: key, optional: true)
                    if !items.isEmpty {
                        Section {
                            ForEach(items, id: \.objectID) { dose in
                                DoseRowView(dose: dose)
                                    .swipeActions(edge: .leading) {
                                        Button { showQuickGivenSheet = dose } label: { Label("Mark Given", systemImage: "checkmark.circle") }
                                            .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) { doseToDelete = dose } label: { Label("Delete", systemImage: "trash") }
                                    }
                            }
                        } header: {
                            Text(keyToHeader(key)).font(.subheadline).foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                        }
                    }
                }
            }
        }
    }

    private func fetchPatientDoses() -> [Dose] {
        let req: NSFetchRequest<Dose> = Dose.fetchRequest()
        req.predicate = NSPredicate(format: "patient == %@", patient)
        req.sortDescriptors = [
            NSSortDescriptor(key: "vaccine.sequence", ascending: true),
            NSSortDescriptor(key: "scheduledDate", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        return (try? context.fetch(req)) ?? []
    }

    private func dosesFor(labelKey: String, optional: Bool) -> [Dose] {
        guard let db = vaccineDB else { return [] }
        let names = (optional ? db.OptionalVaccinationRecord[labelKey] : db.RecommendedVaccinationRecord[labelKey]) ?? []
        let expectedWeeks = keyToWeeks(labelKey)
        let set = Set(names.map { $0.lowercased() })
        // Fetch fresh list from store to avoid stale in-memory set and preserve order by sequence
        let allDoses = fetchPatientDoses()
        // Filter doses for this age group and name list
        let matches = allDoses.filter { dose in
            guard !dose.isDeleted, dose.managedObjectContext != nil else { return false }
            let name = (dose.vaccine?.name ?? "").lowercased()
            if name == "influenza" { // ensure proper band for influenza
                let doseWeeks = Int(dose.vaccine?.recommendedAgeInWeeks ?? 0)
                return set.contains(name) && doseWeeks == expectedWeeks
            }
            return set.contains(name)
        }
        // De-duplicate within the age group: keep earliest per vaccine name
        let grouped = Dictionary(grouping: matches, by: { ($0.vaccine?.name ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        let deduped: [Dose] = grouped.values.compactMap { list in
            // Prefer Given dose, else earliest scheduled
            if let given = list.first(where: { $0.givenOn != nil }) { return given }
            return list.min(by: { $0.scheduledDate < $1.scheduledDate })
        }
        // Apply search filter
        let q = vaccineSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered = q.isEmpty ? deduped : deduped.filter { ($0.vaccine?.name ?? "").lowercased().contains(q) }
        // Sort by vaccine sequence to keep stable order within section
        return filtered.sorted { (lhs, rhs) in
            let ls = Int(lhs.vaccine?.sequence ?? 0)
            let rs = Int(rhs.vaccine?.sequence ?? 0)
            if ls != rs { return ls < rs }
            return lhs.scheduledDate < rhs.scheduledDate
        }
    }

    private func keyToWeeks(_ key: String) -> Int {
        switch key {
        case "AtBirth": return 0
        case "6Weeks": return 6
        case "10Weeks": return 10
        case "14Weeks": return 14
        case "6Months": return 26
        case "7Months": return 30
        case "6to9Months": return 35
        case "9Months": return 39
        case "12Months": return 52
        case "13Months": return 56
        case "15Months": return 65
        case "16to18Months": return 69
        case "18to19Months": return 78
        case "2to3Years": return 104
        case "3to4Years": return 156
        case "4to5Years": return 208
        case "4to6Years": return 260
        case "10to14Years": return 468
        case "9Month": return 39
        case "12Month": return 52
        case "13Month": return 56
        case "After 9Month": return 39
        case "After 2years": return 104
        case "AnyAge": return 0
        default: return 0
        }
    }

    private func keyToHeader(_ key: String) -> String {
        // Map JSON keys to headers with spaces
        return key
            .replacingOccurrences(of: "to", with: " to ")
            .replacingOccurrences(of: "Months", with: " Months")
            .replacingOccurrences(of: "Month", with: " Month")
            .replacingOccurrences(of: "Years", with: " Years")
            .replacingOccurrences(of: "Year", with: " Year")
            .replacingOccurrences(of: "After 2years", with: "After 2 years")
    }

    private func backfillMissingDosesIfNeeded() async {
        guard let db = vaccineDB, !patient.isDeleted else { return }
        let allMap: [(String, [String], Bool)] = VaccineDBLoader.normalOrder.map { ($0, db.RecommendedVaccinationRecord[$0] ?? [], false) } + VaccineDBLoader.optionalOrder.map { ($0, db.OptionalVaccinationRecord[$0] ?? [], true) }
        await context.perform {
            if self.patient.isDeleted { return }
            for (key, names, _) in allMap {
                let expectedWeeks = keyToWeeks(key)
                for name in names {
                    // fetch vaccine by name & weeks
                    let vReq: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
                    vReq.predicate = NSPredicate(format: "name ==[c] %@ AND recommendedAgeInWeeks == %d", name, expectedWeeks)
                    vReq.fetchLimit = 1
                    var vaccine = try? context.fetch(vReq).first
                    if vaccine == nil {
                        // Create the Vaccine master record if missing so doses can be created/repeated per age group
                        let seqReq: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
                        seqReq.sortDescriptors = [NSSortDescriptor(key: "sequence", ascending: false)]
                        seqReq.fetchLimit = 1
                        let nextSeq = (try? context.fetch(seqReq).first?.sequence).map { Int($0) + 1 } ?? 0
                        let v = Vaccine(context: context)
                        v.id = UUID()
                        v.name = name
                        v.recommendedAgeInWeeks = Int16(expectedWeeks)
                        v.sequence = Int16(nextSeq)
                        v.notes = keyToHeader(key)
                        vaccine = v
                    }

                    // check if dose exists for this patient & vaccine & scheduled day
                    let sched = DateHelpers.scheduledDate(dob: patient.dob, weeks: expectedWeeks)
                    let start = Calendar.current.startOfDay(for: sched) as NSDate
                    let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: sched))! as NSDate
                    let dReq: NSFetchRequest<Dose> = Dose.fetchRequest()
                    dReq.predicate = NSPredicate(format: "patient == %@ AND vaccine == %@ AND (scheduledDate >= %@ AND scheduledDate < %@)", patient, vaccine!, start, end)
                    dReq.fetchLimit = 1
                    let exists = ((try? context.fetch(dReq).isEmpty) == false)
                    if !exists {
                        let d = Dose(context: context)
                        d.id = UUID()
                        d.createdAt = Date()
                        d.scheduledDate = sched
                        d.dueDate = sched
                        d.patient = patient
                        d.vaccine = vaccine
                    }
                }
            }
            try? context.save()
        }
    }

    private func cleanupDuplicateVaccinesAndDoses() async {
        await context.perform {
            // 1) Dedup Vaccine masters
            let vReq: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
            guard let allVaccines = try? context.fetch(vReq) else { return }
            let groups = Dictionary(grouping: allVaccines, by: { ( $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) + "|" + String(Int($0.recommendedAgeInWeeks)) ) })

            for (_, variants) in groups where variants.count > 1 {
                // keep the one with smallest sequence
                guard let canonical = variants.min(by: { $0.sequence < $1.sequence }) else { continue }
                for v in variants where v != canonical {
                    // move doses to canonical
                    let dReq: NSFetchRequest<Dose> = Dose.fetchRequest()
                    dReq.predicate = NSPredicate(format: "vaccine == %@", v)
                    if let doses = try? context.fetch(dReq) {
                        for d in doses { d.vaccine = canonical }
                    }
                    context.delete(v)
                }
            }

            // 2) Dedup Doses per patient+vaccine+scheduledDate(day)
            let doseReq: NSFetchRequest<Dose> = Dose.fetchRequest()
            guard let allDoses = try? context.fetch(doseReq) else { return }
            let cal = Calendar.current
            let dGroups = Dictionary(grouping: allDoses, by: { dose -> String in
                let p = dose.patient?.objectID.uriRepresentation().absoluteString ?? "nilp"
                let v = dose.vaccine?.objectID.uriRepresentation().absoluteString ?? "nilv"
                let day = cal.startOfDay(for: dose.scheduledDate)
                let iso = ISO8601DateFormatter().string(from: day)
                return p + "|" + v + "|" + iso
            })
            for (_, list) in dGroups where list.count > 1 {
                // Prefer a dose that has been given; otherwise keep earliest created
                let keep = list.max(by: { (lhs, rhs) in
                    let lGiven = lhs.givenOn != nil
                    let rGiven = rhs.givenOn != nil
                    if lGiven != rGiven { return !lGiven && rGiven } // prefer true
                    return lhs.createdAt > rhs.createdAt // keep most recent if tie
                })
                for d in list { if d != keep { context.delete(d) } }
            }

            try? context.save()
        }
    }

    private func performDeleteDose(_ dose: Dose) {
        // Delete all visually-identical doses (same patient, vaccine and scheduled day)
        let cal = Calendar.current
        let day = cal.startOfDay(for: dose.scheduledDate)
        let fetch: NSFetchRequest<Dose> = Dose.fetchRequest()
        if let vaccine = dose.vaccine {
            fetch.predicate = NSPredicate(format: "patient == %@ AND vaccine == %@", patient, vaccine)
        } else {
            fetch.predicate = NSPredicate(format: "patient == %@ AND vaccine == nil", patient)
        }
        if let matches = try? context.fetch(fetch) {
            for d in matches where cal.isDate(cal.startOfDay(for: d.scheduledDate), inSameDayAs: day) {
                context.delete(d)
            }
        } else {
            context.delete(dose)
        }
        do {
            try context.save()
            // Refresh context to ensure UI updates immediately
            context.refreshAllObjects()
            // Local de-duplication to prevent a visually identical duplicate remaining
            let fetch: NSFetchRequest<Dose> = Dose.fetchRequest()
            fetch.predicate = NSPredicate(format: "patient == %@", patient)
            if let all = try? context.fetch(fetch) {
                let groups = Dictionary(grouping: all, by: { d -> String in
                    let v = d.vaccine?.objectID.uriRepresentation().absoluteString ?? "nilv"
                    let day = cal.startOfDay(for: d.scheduledDate)
                    let iso = ISO8601DateFormatter().string(from: day)
                    return v + "|" + iso
                })
                for (_, list) in groups where list.count > 1 {
                    let keep = list.min(by: { $0.createdAt < $1.createdAt })
                    for d in list { if d != keep { context.delete(d) } }
                }
                try? context.save()
                context.refreshAllObjects()
            }
        } catch {
            context.rollback()
        }
    }

    private func performDeletePatient() {
        context.delete(patient)
        do {
            try context.save()
            // Dismiss detail view to avoid rendering deleted objects
            dismiss()
        } catch {
            context.rollback()
        }
    }
}

// Compact quick mark given sheet
struct QuickGivenSheet: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var givenOn: Date = Date()
    @State private var batchNumber: String = ""
    @State private var facility: String = ""

    let dose: Dose

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Given On", selection: $givenOn, displayedComponents: [.date, .hourAndMinute])
                TextField("Batch Number", text: $batchNumber)
                TextField("Facility", text: $facility)
            }
            .navigationTitle("Mark Given")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dose.givenOn = givenOn
                        if !batchNumber.isEmpty { dose.batchNumber = batchNumber }
                        if !facility.isEmpty { dose.facility = facility }
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            context.rollback()
                        }
                    }
                }
            }
        }
    }
}


