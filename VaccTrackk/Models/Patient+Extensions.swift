import Foundation
import CoreData

@objc(Patient)
public class Patient: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        NSFetchRequest<Patient>(entityName: "Patient")
    }
}

extension Patient {
    @NSManaged public var id: UUID
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String?
    @NSManaged public var motherName: String?
    @NSManaged public var fatherName: String?
    @NSManaged public var gender: String?
    @NSManaged public var dob: Date
    @NSManaged public var timeOfBirth: String?
    @NSManaged public var modeOfDelivery: String?
    @NSManaged public var birthWeightGrams: Int16
    @NSManaged public var lengthCm: Int16
    @NSManaged public var headCircumferenceCm: Float
    @NSManaged public var contactNumber: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var doses: Set<Dose>?

    public var displayName: String {
        let last = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return [firstName, last].filter { !$0.isEmpty }.joined(separator: " ")
    }

    public var sortedDoses: [Dose] {
        (doses ?? []).sorted { $0.scheduledDate < $1.scheduledDate }
    }

    public var upcomingDoses: [Dose] {
        sortedDoses.filter { $0.givenOn == nil }
    }

    public var nextDueDate: Date? {
        upcomingDoses.first?.scheduledDate
    }
}


