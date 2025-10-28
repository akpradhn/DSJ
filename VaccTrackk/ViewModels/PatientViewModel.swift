import Foundation
import CoreData

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

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && dob <= Date()
    }

    @discardableResult
    func saveAndGenerateDosesIfNeeded(seedVaccines vaccines: [Vaccine]? = nil) throws -> Patient {
        let p: Patient = patient ?? Patient(context: context)
        if patient == nil {
            p.id = UUID()
            p.createdAt = Date()
        }
        p.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        p.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : lastName
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

        // Generate doses only when creating a new patient without doses
        if (p.doses?.isEmpty ?? true) {
            let vaccinesToUse: [Vaccine]
            if let vaccines = vaccines {
                vaccinesToUse = vaccines
            } else {
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

    var upcomingDoses: [Dose] {
        guard let p = patient else { return [] }
        return p.upcomingDoses
    }

    var nextDueDate: Date? {
        patient?.nextDueDate
    }
}


