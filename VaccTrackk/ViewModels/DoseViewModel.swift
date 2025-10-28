import Foundation
import CoreData

final class DoseViewModel: ObservableObject {
    @Published var scheduledDate: Date = Date()
    @Published var givenOn: Date? = nil
    @Published var batchNumber: String = ""
    @Published var facility: String = ""
    @Published var administeredBy: String = ""
    @Published var notes: String = ""

    private let context: NSManagedObjectContext
    private(set) var dose: Dose
    private let patientDOB: Date

    init(context: NSManagedObjectContext, dose: Dose, patientDOB: Date) {
        self.context = context
        self.dose = dose
        self.patientDOB = patientDOB

        scheduledDate = dose.scheduledDate
        givenOn = dose.givenOn
        batchNumber = dose.batchNumber ?? ""
        facility = dose.facility ?? ""
        administeredBy = dose.administeredBy ?? ""
        notes = dose.notes ?? ""
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
        try context.save()
    }

    func markGivenNow(batch: String?, facility: String?) {
        dose.givenOn = Date()
        if let b = batch, !b.isEmpty { dose.batchNumber = b }
        if let f = facility, !f.isEmpty { dose.facility = f }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    func delete() throws {
        context.delete(dose)
        try context.save()
    }
}


