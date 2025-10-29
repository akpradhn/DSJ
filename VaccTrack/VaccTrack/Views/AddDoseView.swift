import SwiftUI
import CoreData

struct AddDoseView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let patient: Patient

    @State private var selectedVaccine: Vaccine?
    @State private var scheduledDate: Date = Date()
    @State private var vaccines: [Vaccine] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    // Age groups shown to user (mapped to approximate weeks) - matches VaccineDB.json
    private let ageBuckets: [(label: String, weeks: Int)] = [
        ("At Birth", 0), ("6 Weeks", 6), ("10 Weeks", 10), ("14 Weeks", 14),
        ("6 Months", 26), ("7 Months", 30), ("6–9 Months", 35), ("9 Months", 39),
        ("12 Months", 52), ("13 Months", 56), ("15 Months", 65), ("16–18 Months", 69),
        ("18–19 Months", 78), ("2–3 Years", 104), ("3–4 Years", 156), ("4–5 Years", 208), ("4–6 Years", 260),
        ("9–14 Years", 468), ("After 9 Months", 39), ("Any Age", 0)
    ]
    @State private var selectedWeeks: Int = 0

    var body: some View {
        Form {
            NavigationLink {
                VaccineSelectView(vaccines: vaccines, selection: Binding(get: { selectedVaccine }, set: { selectedVaccine = $0 }))
            } label: {
                HStack { Text("Vaccine"); Spacer(); Text(selectedVaccine?.name ?? "Select").foregroundColor(.secondary) }
            }
            .onChange(of: selectedVaccine) { _, newValue in
                // When vaccine changes, move age group to that vaccine's recommended weeks (if present)
                let weeks = Int(newValue?.recommendedAgeInWeeks ?? 0)
                if ageBuckets.map({ $0.weeks }).contains(weeks) {
                    selectedWeeks = weeks
                    scheduledDate = DateHelpers.scheduledDate(dob: patient.dob, weeks: weeks)
                }
            }
            NavigationLink {
                AgeGroupSelectView(buckets: ageBuckets, selectionWeeks: $selectedWeeks)
            } label: {
                HStack { Text("Age Group"); Spacer(); Text(ageBuckets.first(where: { $0.weeks == selectedWeeks })?.label ?? "Select").foregroundColor(.secondary) }
            }
            .onChange(of: selectedWeeks) { _, newWeeks in
                scheduledDate = DateHelpers.scheduledDate(dob: patient.dob, weeks: newWeeks)
            }
            DatePicker("Scheduled Date", selection: $scheduledDate, in: patient.dob...Date.distantFuture, displayedComponents: .date)
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
        .alert("Failed to Add Dose", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
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
        guard let v = selectedVaccine else { 
            errorMessage = "Please select a vaccine before adding the dose."
            showErrorAlert = true
            return 
        }
        
        // Validate scheduled date (allow same calendar day as DOB)
        let cal = Calendar.current
        let scheduledDay = cal.startOfDay(for: scheduledDate)
        let dobDay = cal.startOfDay(for: patient.dob)
        if scheduledDay < dobDay {
            errorMessage = "Scheduled date cannot be before the patient's date of birth."
            showErrorAlert = true
            return
        }
        
        // Check if dose already exists for this vaccine and patient
        let existingDoseRequest: NSFetchRequest<Dose> = Dose.fetchRequest()
        existingDoseRequest.predicate = NSPredicate(format: "patient == %@ AND vaccine == %@", patient, v)
        existingDoseRequest.fetchLimit = 1
        
        if let existingDoses = try? context.fetch(existingDoseRequest), !existingDoses.isEmpty {
            errorMessage = "A dose for \(v.name) has already been added for this patient."
            showErrorAlert = true
            return
        }
        
        let dose = Dose(context: context)
        dose.id = UUID()
        dose.createdAt = Date()
        dose.scheduledDate = scheduledDate
        dose.dueDate = scheduledDate
        dose.patient = patient
        dose.vaccine = v
        
        do { 
            try context.save()
            dismiss() 
        } catch let error as NSError {
            context.rollback()
            
            // Provide specific error messages based on the error
            if error.domain == "NSCocoaErrorDomain" {
                switch error.code {
                case 133000: // NSValidationErrorMinimum
                    errorMessage = "Invalid data provided. Please check all fields and try again."
                case 133005: // NSValidationErrorRelationshipDenied
                    errorMessage = "Unable to link dose to patient. Please try again."
                case 133020: // NSValidationErrorMultipleErrors
                    errorMessage = "Multiple validation errors occurred. Please check all fields."
                default:
                    errorMessage = "Database error occurred: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Failed to save dose: \(error.localizedDescription)"
            }
            showErrorAlert = true
        }
    }
}
