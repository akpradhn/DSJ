import SwiftUI
import CoreData

struct AddDoseView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let patient: Patient

    @State private var selectedVaccine: Vaccine?
    @State private var scheduledDate: Date = Date()
    @State private var vaccines: [Vaccine] = []

    // Age groups shown to user (weeks)
    private let ageBuckets: [(label: String, weeks: Int)] = [
        ("At Birth", 0), ("6 Weeks", 6), ("10 Weeks", 10), ("14 Weeks", 14),
        ("6 Months", 26), ("9 Months", 39), ("12 Months", 52), ("15 Months", 65),
        ("16–18 Months", 69), ("18–19 Months", 78), ("2–3 Years", 104), ("3–4 Years", 156), ("4–5 Years", 208), ("4–6 Years", 260), ("10–14 Years", 520)
    ]
    @State private var selectedWeeks: Int = 0

    var body: some View {
        Form {
            Picker("Vaccine", selection: $selectedVaccine) {
                ForEach(vaccines, id: \.objectID) { v in
                    Text(v.name).tag(Optional(v))
                }
            }
            Picker("Age Group", selection: $selectedWeeks) {
                ForEach(ageBuckets, id: \.weeks) { bucket in
                    Text(bucket.label).tag(bucket.weeks)
                }
            }
            .onChange(of: selectedWeeks) { _, newWeeks in
                scheduledDate = DateHelpers.scheduledDate(dob: patient.dob, weeks: newWeeks)
            }
            DatePicker("Scheduled Date", selection: $scheduledDate, displayedComponents: .date)
            Section {
                Button("Add Dose") { add() }
                    .disabled(selectedVaccine == nil)
            }
        }
        .navigationTitle("Add Dose")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        }
        .onAppear(perform: loadVaccines)
    }

    private func loadVaccines() {
        let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "sequence", ascending: true)]
        vaccines = (try? context.fetch(req)) ?? []
        if selectedVaccine == nil { selectedVaccine = vaccines.first }
        // Default group: use selected vaccine recommended weeks if available
        let defaultWeeks = Int(selectedVaccine?.recommendedAgeInWeeks ?? 0)
        selectedWeeks = ageBuckets.map { $0.weeks }.contains(defaultWeeks) ? defaultWeeks : 0
        scheduledDate = DateHelpers.scheduledDate(dob: patient.dob, weeks: selectedWeeks)
    }

    private func add() {
        guard let v = selectedVaccine else { return }
        let dose = Dose(context: context)
        dose.id = UUID()
        dose.createdAt = Date()
        dose.scheduledDate = scheduledDate
        dose.dueDate = scheduledDate
        dose.patient = patient
        dose.vaccine = v
        do { try context.save(); dismiss() } catch { context.rollback() }
    }
}
