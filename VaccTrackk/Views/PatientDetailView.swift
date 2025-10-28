import SwiftUI

struct PatientDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingEdit = false
    @State private var showingShare = false
    @State private var exportItems: [Any] = []
    @State private var showQuickGivenSheet: Dose?

    let patient: Patient

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                birthDetailsCard
                scheduleList
            }
            .padding()
        }
        .navigationTitle(Text(patient.displayName))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                Menu {
                    Button {
                        exportJSON()
                    } label: {
                        Label("Export JSON", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        exportPDF()
                    } label: {
                        Label("Export PDF", systemImage: "doc.richtext")
                    }
                    Button(role: .destructive) {
                        deletePatient()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                PatientFormView(patient: patient, onSaved: { _ in
                    showingEdit = false
                }, onCancel: {
                    showingEdit = false
                })
                .environment(\.managedObjectContext, context)
            }
        }
        .sheet(isPresented: $showingShare) {
            ActivityView(activityItems: exportItems)
        }
        .sheet(item: $showQuickGivenSheet) { dose in
            QuickGivenSheet(dose: dose, patient: patient)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(patient.displayName)
                .font(.title2.bold())
            Text("DOB: \(DateHelpers.formatDate(patient.dob))")
                .foregroundColor(.secondary)
            if let mother = patient.motherName {
                Text("Mother: \(mother)")
                    .foregroundColor(.secondary)
            }
            if let father = patient.fatherName {
                Text("Father: \(father)")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 1))
    }

    private var birthDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(Formatters.grams(Int(patient.birthWeightGrams)), systemImage: "scalemass")
                Spacer()
                Label("\(patient.lengthCm) cm", systemImage: "ruler")
                Spacer()
                Label(String(format: "%.1f cm", patient.headCircumferenceCm), systemImage: "circle.lefthalf.filled")
            }
            if let mode = patient.modeOfDelivery, !mode.isEmpty {
                Text("Delivery: \(mode)")
                    .foregroundColor(.secondary)
            }
            if let time = patient.timeOfBirth, !time.isEmpty {
                Text("Time of Birth: \(time)")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private var scheduleList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vaccine Schedule")
                .font(.headline)
            ForEach(groupedDoses.keys.sorted(), id: \.self) { label in
                Section {
                    ForEach(groupedDoses[label] ?? [], id: \.objectID) { dose in
                        DoseRowView(dose: dose)
                            .swipeActions(edge: .leading) {
                                Button {
                                    showQuickGivenSheet = dose
                                } label: {
                                    Label("Mark Given", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteDose(dose)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(label).font(.subheadline).foregroundColor(.secondary)
                }
            }
        }
    }

    private var groupedDoses: [String: [Dose]] {
        let doses = patient.sortedDoses
        let grouped = Dictionary(grouping: doses) { dose -> String in
            let weeks = dose.vaccine?.recommendedAgeInWeeks ?? 0
            return DateHelpers.milestoneLabel(weeks: Int(weeks))
        }
        return grouped.mapValues { $0.sorted { $0.scheduledDate < $1.scheduledDate } }
    }

    private func deleteDose(_ dose: Dose) {
        context.delete(dose)
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    private func deletePatient() {
        context.delete(patient)
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    private func exportJSON() {
        do {
            let data = try ExportImportService.exportPatientAsJSON(patient: patient)
            exportItems = [data.tempFileURL(filename: "\(patient.displayName).json")]
            showingShare = true
        } catch {
        }
    }

    private func exportPDF() {
        let pdfData = PDFGenerator.generatePatientPDF(patient: patient)
        exportItems = [pdfData.tempFileURL(filename: "\(patient.displayName).pdf")]
        showingShare = true
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct QuickGivenSheet: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var givenOn = Date()
    @State private var batchNumber = ""
    @State private var facility = ""

    let dose: Dose
    let patient: Patient

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Given On", selection: $givenOn, displayedComponents: [.date, .hourAndMinute])
                TextField("Batch Number", text: $batchNumber)
                TextField("Facility", text: $facility)
            }
            .navigationTitle(Text("Mark Given"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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


