import SwiftUI
import CoreData

struct PatientDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingEdit = false
    @State private var showQuickGivenSheet: Dose?
    @State private var showAddDose = false

    @State private var confirmDeletePatient = false
    @State private var doseToDelete: Dose?

    let patient: Patient

    // Gracefully handle potentially missing DOB values from older data
    private var safeDOB: Date { (patient.value(forKey: "dob") as? Date) ?? Date() }

    private let ageBuckets: [(label: String, weeks: Int)] = [
        ("At Birth", 0),
        ("6 Weeks", 6), ("10 Weeks", 10), ("14 Weeks", 14),
        ("6 Months", 26), ("9 Months", 39), ("12 Months", 52), ("15 Months", 65),
        ("16–18 Months", 69), ("18–19 Months", 78),
        ("2–3 Years", 104), ("3–4 Years", 156), ("4–5 Years", 208), ("4–6 Years", 260),
        ("10–14 Years", 520)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                actions
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
            Text("Vaccination Schedule").font(.title3.bold())
            ForEach(ageBuckets, id: \.weeks) { bucket in
                let doses = dosesFor(weeks: bucket.weeks)
                if !doses.isEmpty {
                    Section {
                        ForEach(doses, id: \.objectID) { dose in
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
                        Text(bucket.label).font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                    }
                }
            }
        }
    }

    private func dosesFor(weeks: Int) -> [Dose] { patient.sortedDoses.filter { Int($0.vaccine?.recommendedAgeInWeeks ?? 0) == weeks } }

    private func performDeleteDose(_ dose: Dose) {
        context.delete(dose)
        do { try context.save() } catch { context.rollback() }
    }

    private func performDeletePatient() {
        context.delete(patient)
        do { try context.save() } catch { context.rollback() }
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


