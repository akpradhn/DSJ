import Foundation
import CoreData
import Combine

final class DoseViewModel: ObservableObject {
    @Published var scheduledDate: Date = Date()
    @Published var givenOn: Date? = nil
    @Published var batchNumber: String = ""
    @Published var facility: String = ""
    @Published var administeredBy: String = ""
    @Published var notes: String = ""
    
    // New fields for dose details
    @Published var weightAtDose: Float = 0.0
    @Published var heightAtDose: Float = 0.0
    @Published var headCircumferenceAtDose: Float = 0.0
    @Published var vaccineBrand: String = ""

    private let context: NSManagedObjectContext
    private(set) var dose: Dose
    private let patientDOB: Date

    init(context: NSManagedObjectContext, dose: Dose, patientDOB: Date) {
        self.context = context
        self.dose = dose
        self.patientDOB = patientDOB

        // Use KVC to avoid crashes if legacy objects have nils for non-optional attributes
        scheduledDate = (dose.value(forKey: "scheduledDate") as? Date) ?? Date()
        givenOn = dose.value(forKey: "givenOn") as? Date
        batchNumber = (dose.value(forKey: "batchNumber") as? String) ?? ""
        facility = (dose.value(forKey: "facility") as? String) ?? ""
        administeredBy = (dose.value(forKey: "administeredBy") as? String) ?? ""
        notes = (dose.value(forKey: "notes") as? String) ?? ""
        
        // Load new fields
        weightAtDose = (dose.value(forKey: "weightAtDose") as? Float) ?? 0.0
        heightAtDose = (dose.value(forKey: "heightAtDose") as? Float) ?? 0.0
        headCircumferenceAtDose = (dose.value(forKey: "headCircumferenceAtDose") as? Float) ?? 0.0
        vaccineBrand = (dose.value(forKey: "vaccineBrand") as? String) ?? ""
    }

    var status: DoseStatus { dose.status }

    func validate() -> String? {
        if let given = givenOn, given < patientDOB {
            return NSLocalizedString("Given date cannot be before DOB.", comment: "validation")
        }
        return nil
    }

    func save() throws {
        if let error = validate() {
            throw NSError(domain: "DoseValidation", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
        }
        dose.scheduledDate = scheduledDate
        dose.dueDate = scheduledDate
        dose.givenOn = givenOn
        dose.batchNumber = batchNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : batchNumber
        dose.facility = facility.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : facility
        dose.administeredBy = administeredBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : administeredBy
        dose.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        
        // Save new fields
        dose.weightAtDose = weightAtDose
        dose.heightAtDose = heightAtDose
        dose.headCircumferenceAtDose = headCircumferenceAtDose
        dose.vaccineBrand = vaccineBrand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : vaccineBrand
        try context.save()
    }

    func markGivenNow(batch: String?, facility: String?) {
        dose.givenOn = Date()
        if let b = batch, !b.isEmpty { dose.batchNumber = b }
        if let f = facility, !f.isEmpty { dose.facility = f }
        do { try context.save() } catch { context.rollback() }
    }

    func delete() throws { context.delete(dose); try context.save() }
}


