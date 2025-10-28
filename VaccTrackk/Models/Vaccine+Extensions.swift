import Foundation
import CoreData

@objc(Vaccine)
public class Vaccine: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vaccine> {
        NSFetchRequest<Vaccine>(entityName: "Vaccine")
    }
}

extension Vaccine {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var recommendedAgeInWeeks: Int16
    @NSManaged public var sequence: Int16
    @NSManaged public var notes: String?
    @NSManaged public var doses: Set<Dose>?
}


