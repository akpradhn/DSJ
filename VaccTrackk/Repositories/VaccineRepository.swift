import Foundation
import CoreData

enum VaccineRepository {
    static func seedVaccinesIfNeeded(context: NSManagedObjectContext) async {
        let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
        req.fetchLimit = 1
        let count: Int
        do {
            count = try context.count(for: req)
        } catch {
            print("Count vaccines failed: \(error)")
            return
        }
        if count > 0 { return }

        guard let url = Bundle.main.url(forResource: "PreseedVaccines", withExtension: "json") else {
            print("PreseedVaccines.json not found")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([SeedVaccine].self, from: data)
            try await context.perform {
                for (index, item) in items.enumerated() {
                    let v = Vaccine(context: context)
                    v.id = item.id ?? UUID()
                    v.name = item.name
                    v.recommendedAgeInWeeks = Int16(item.recommendedAgeInWeeks)
                    v.sequence = Int16(item.sequence ?? index)
                    v.notes = item.notes
                }
                try context.save()
            }
        } catch {
            print("Seeding vaccines failed: \(error)")
        }
    }

    struct SeedVaccine: Codable {
        var id: UUID?
        var name: String
        var recommendedAgeInWeeks: Int
        var sequence: Int?
        var notes: String?
    }
}


