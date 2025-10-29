import Foundation
import CoreData
import Combine

final class PatientViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var motherName: String = ""
    @Published var fatherName: String = ""
    @Published var gender: String = ""
    @Published var dob: Date = Date()
    @Published var timeOfBirth: String = ""
    @Published var modeOfDelivery: String = ""
    @Published var birthWeightGrams: Int = 0
    @Published var lengthCm: Int = 0
    @Published var headCircumferenceCm: Float = 0
    @Published var contactNumber: String = ""
    @Published var notes: String = ""

    private let context: NSManagedObjectContext
    private(set) var patient: Patient?

    init(context: NSManagedObjectContext, patient: Patient? = nil) {
        self.context = context
        self.patient = patient

        if let p = patient {
            firstName = p.firstName
            lastName = p.lastName ?? ""
            motherName = p.motherName ?? ""
            fatherName = p.fatherName ?? ""
            gender = p.gender ?? ""
            dob = p.dob
            timeOfBirth = p.timeOfBirth ?? ""
            modeOfDelivery = p.modeOfDelivery ?? ""
            birthWeightGrams = Int(p.birthWeightGrams)
            lengthCm = Int(p.lengthCm)
            headCircumferenceCm = p.headCircumferenceCm
            contactNumber = p.contactNumber ?? ""
            notes = p.notes ?? ""
        }
    }

    var isValid: Bool { !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && dob <= Date() }

    @discardableResult
    func saveAndGenerateDosesIfNeeded(seedVaccines vaccines: [Vaccine]? = nil) throws -> Patient {
        // Duplicate validation: same first+last name (case/space insensitive) on same calendar day
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: dob)
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!

        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "firstName =[c] %@", trimmedFirst))
        if trimmedLast.isEmpty {
            predicates.append(NSPredicate(format: "lastName == nil OR lastName == ''"))
        } else {
            predicates.append(NSPredicate(format: "lastName =[c] %@", trimmedLast))
        }
        predicates.append(NSPredicate(format: "dob >= %@ AND dob < %@", dayStart as NSDate, dayEnd as NSDate))
        if let existing = patient { // exclude self when editing
            predicates.append(NSPredicate(format: "self != %@", existing))
        }
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let dupCount = (try? context.count(for: req)) ?? 0
        if dupCount > 0 {
            throw NSError(domain: "PatientValidation", code: 1001, userInfo: [NSLocalizedDescriptionKey: "A patient with the same name and date of birth already exists."])
        }

        let p: Patient = patient ?? Patient(context: context)
        if patient == nil { p.id = UUID(); p.createdAt = Date() }
        p.firstName = trimmedFirst
        p.lastName = trimmedLast.isEmpty ? nil : trimmedLast
        p.motherName = motherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : motherName
        p.fatherName = fatherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : fatherName
        p.gender = gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : gender
        p.dob = dob
        p.timeOfBirth = timeOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : timeOfBirth
        p.modeOfDelivery = modeOfDelivery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : modeOfDelivery
        p.birthWeightGrams = Int16(birthWeightGrams)
        p.lengthCm = Int16(lengthCm)
        p.headCircumferenceCm = headCircumferenceCm
        p.contactNumber = contactNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : contactNumber
        p.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes

        if (p.doses?.isEmpty ?? true) {
            let vaccinesToUse: [Vaccine]
            if let vaccines = vaccines { vaccinesToUse = vaccines } else {
                let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
                req.sortDescriptors = [NSSortDescriptor(key: "sequence", ascending: true)]
                vaccinesToUse = (try? context.fetch(req)) ?? []
            }
            for v in vaccinesToUse.sorted(by: { $0.sequence < $1.sequence }) {
                let dose = Dose(context: context)
                dose.id = UUID()
                dose.createdAt = Date()
                let scheduled = DateHelpers.scheduledDate(dob: p.dob, weeks: Int(v.recommendedAgeInWeeks))
                dose.scheduledDate = scheduled
                dose.dueDate = scheduled
                dose.patient = p
                dose.vaccine = v
            }
        }

        try context.save()
        self.patient = p
        return p
    }

    var upcomingDoses: [Dose] { guard let p = patient else { return [] }; return p.upcomingDoses }
    var nextDueDate: Date? { patient?.nextDueDate }

    // MARK: - Dose Editing API
    func addDose(vaccine: Vaccine, scheduledOn: Date?) throws {
        guard let p = patient else { return }
        let dose = Dose(context: context)
        dose.id = UUID()
        dose.createdAt = Date()
        let date = scheduledOn ?? DateHelpers.scheduledDate(dob: p.dob, weeks: Int(vaccine.recommendedAgeInWeeks))
        dose.scheduledDate = date
        dose.dueDate = date
        dose.patient = p
        dose.vaccine = vaccine
        try context.save()
    }

    func removeDose(_ dose: Dose) throws {
        context.delete(dose)
        try context.save()
    }
}


