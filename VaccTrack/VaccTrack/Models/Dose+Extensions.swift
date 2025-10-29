import Foundation
import CoreData
import SwiftUI

@objc(Dose)
public class Dose: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dose> {
        NSFetchRequest<Dose>(entityName: "Dose")
    }
}

// Allow SwiftUI to identify Dose by its 'id'
extension Dose: Identifiable {}

extension Dose {
    @NSManaged public var id: UUID
    @NSManaged public var scheduledDate: Date
    @NSManaged public var dueDate: Date?
    @NSManaged public var givenOn: Date?
    @NSManaged public var batchNumber: String?
    @NSManaged public var facility: String?
    @NSManaged public var administeredBy: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    
    // New fields for dose details
    @NSManaged public var weightAtDose: Float
    @NSManaged public var heightAtDose: Float
    @NSManaged public var headCircumferenceAtDose: Float
    @NSManaged public var vaccineBrand: String?
    @NSManaged public var photoData: Data?

    @NSManaged public var patient: Patient?
    @NSManaged public var vaccine: Vaccine?

    public var status: DoseStatus {
        if let given = givenOn {
            return .given(given)
        }
        let now = Date()
        if scheduledDate > now {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now), to: Calendar.current.startOfDay(for: scheduledDate)).day ?? 0
            return .upcoming(max(days, 0))
        } else {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: scheduledDate), to: Calendar.current.startOfDay(for: now)).day ?? 0
            if days > 0 { return .overdue(days) }
            return .notGiven
        }
    }
}

public enum DoseStatus: Equatable {
    case notGiven
    case upcoming(Int) // days until due
    case given(Date)
    case overdue(Int) // days overdue

    public var color: Color {
        switch self {
        case .given: return .green
        case .upcoming: return .yellow
        case .overdue: return .red
        case .notGiven: return .secondary
        }
    }

    public var iconName: String {
        switch self {
        case .given: return "checkmark.circle.fill"
        case .upcoming: return "clock.fill"
        case .overdue: return "exclamationmark.triangle.fill"
        case .notGiven: return "circle"
        }
    }
}


