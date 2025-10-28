import Foundation
import CoreData

enum VaccineRepository {
    static func seedVaccinesIfNeeded(context: NSManagedObjectContext) async {
        let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
        req.fetchLimit = 1
        let count = (try? context.count(for: req)) ?? 0
        if count > 0 { return }

        let items: [SeedVaccine] = hardcodedVaccines()
        do {
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

    private static func hardcodedVaccines() -> [SeedVaccine] {
        // Helper to convert months/years to weeks (approx; aligns with earlier seeds: 12m=52w, 15m=65w)
        func m(_ months: Int) -> Int { Int(Double(months) * 4.33).clamped(min: 0) }
        func y(_ years: Int) -> Int { m(years * 12) }

        return [
            // Birth and infancy
            SeedVaccine(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001"), name: "BCG", recommendedAgeInWeeks: 0, sequence: 0, notes: "Birth"),
            SeedVaccine(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002"), name: "OPV-0", recommendedAgeInWeeks: 0, sequence: 1, notes: "Birth"),
            SeedVaccine(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003"), name: "HepB-0", recommendedAgeInWeeks: 0, sequence: 2, notes: "Birth"),
            SeedVaccine(id: nil, name: "DTP-1", recommendedAgeInWeeks: 6, sequence: 3, notes: nil),
            SeedVaccine(id: nil, name: "IPV-1", recommendedAgeInWeeks: 6, sequence: 4, notes: nil),
            SeedVaccine(id: nil, name: "Hib-1", recommendedAgeInWeeks: 6, sequence: 5, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-1", recommendedAgeInWeeks: 6, sequence: 6, notes: nil),
            SeedVaccine(id: nil, name: "PCV-1", recommendedAgeInWeeks: 6, sequence: 7, notes: nil),
            SeedVaccine(id: nil, name: "DTP-2", recommendedAgeInWeeks: 10, sequence: 8, notes: nil),
            SeedVaccine(id: nil, name: "IPV-2", recommendedAgeInWeeks: 10, sequence: 9, notes: nil),
            SeedVaccine(id: nil, name: "Hib-2", recommendedAgeInWeeks: 10, sequence: 10, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-2", recommendedAgeInWeeks: 10, sequence: 11, notes: nil),
            SeedVaccine(id: nil, name: "PCV-2", recommendedAgeInWeeks: 10, sequence: 12, notes: nil),
            SeedVaccine(id: nil, name: "DTP-3", recommendedAgeInWeeks: 14, sequence: 13, notes: nil),
            SeedVaccine(id: nil, name: "IPV-3", recommendedAgeInWeeks: 14, sequence: 14, notes: nil),
            SeedVaccine(id: nil, name: "Hib-3", recommendedAgeInWeeks: 14, sequence: 15, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-3", recommendedAgeInWeeks: 14, sequence: 16, notes: nil),
            SeedVaccine(id: nil, name: "PCV-3", recommendedAgeInWeeks: 14, sequence: 17, notes: nil),
            SeedVaccine(id: nil, name: "Influenza-1", recommendedAgeInWeeks: 26, sequence: 18, notes: "6 months"),
            SeedVaccine(id: nil, name: "MMR-1", recommendedAgeInWeeks: 39, sequence: 19, notes: "9 months"),
            SeedVaccine(id: nil, name: "HepA-1", recommendedAgeInWeeks: 52, sequence: 20, notes: "12 months"),
            SeedVaccine(id: nil, name: "MMR-2", recommendedAgeInWeeks: 65, sequence: 21, notes: "15 months"),
            SeedVaccine(id: nil, name: "Varicella-1", recommendedAgeInWeeks: 65, sequence: 22, notes: "15 months"),

            // 16–18 Months (approx 70–78 weeks)
            SeedVaccine(id: nil, name: "DTwP/DTaP-B1", recommendedAgeInWeeks: m(16), sequence: 23, notes: "16–18 months"),
            SeedVaccine(id: nil, name: "IPV-B1", recommendedAgeInWeeks: m(16), sequence: 24, notes: "16–18 months"),
            SeedVaccine(id: nil, name: "Hib-B1", recommendedAgeInWeeks: m(16), sequence: 25, notes: "16–18 months"),

            // 18–19 Months
            SeedVaccine(id: nil, name: "HepA-2", recommendedAgeInWeeks: m(18), sequence: 26, notes: "18–19 months"),
            SeedVaccine(id: nil, name: "Varicella-2", recommendedAgeInWeeks: m(18), sequence: 27, notes: "18–19 months"),

            // 2–3 Years
            SeedVaccine(id: nil, name: "Influenza (2–3y)", recommendedAgeInWeeks: y(2), sequence: 28, notes: "2–3 years"),
            // 3–4 Years
            SeedVaccine(id: nil, name: "Influenza (3–4y)", recommendedAgeInWeeks: y(3), sequence: 29, notes: "3–4 years"),
            // 4–5 Years
            SeedVaccine(id: nil, name: "Influenza (4–5y)", recommendedAgeInWeeks: y(4), sequence: 30, notes: "4–5 years"),

            // 4–6 Years Boosters
            SeedVaccine(id: nil, name: "DTwP/DTaP-B2", recommendedAgeInWeeks: y(5), sequence: 31, notes: "4–6 years"),
            SeedVaccine(id: nil, name: "IPV-B2", recommendedAgeInWeeks: y(5), sequence: 32, notes: "4–6 years"),
            SeedVaccine(id: nil, name: "MMR-3", recommendedAgeInWeeks: y(5), sequence: 33, notes: "4–6 years"),
            SeedVaccine(id: nil, name: "Tdap", recommendedAgeInWeeks: y(5), sequence: 34, notes: "4–6 years"),

            // 10–14 Years
            SeedVaccine(id: nil, name: "HPV-1", recommendedAgeInWeeks: y(10), sequence: 35, notes: "10–14 years"),
            SeedVaccine(id: nil, name: "HPV-2", recommendedAgeInWeeks: y(10) + 26, sequence: 36, notes: "10–14 years (dose 2)"),

            // Optional Vaccines from card
            SeedVaccine(id: nil, name: "MCV-1", recommendedAgeInWeeks: 39, sequence: 40, notes: "Optional 9 months"),
            SeedVaccine(id: nil, name: "MCV-2", recommendedAgeInWeeks: 52, sequence: 41, notes: "Optional 12 months"),
            SeedVaccine(id: nil, name: "JE-1", recommendedAgeInWeeks: 52, sequence: 42, notes: "Optional 12 months"),
            SeedVaccine(id: nil, name: "Cholera-1", recommendedAgeInWeeks: 52, sequence: 43, notes: "Optional 12 months"),
            SeedVaccine(id: nil, name: "JE-2", recommendedAgeInWeeks: 56, sequence: 44, notes: "Optional 13 months"),
            SeedVaccine(id: nil, name: "Cholera-2", recommendedAgeInWeeks: 56, sequence: 45, notes: "Optional 13 months"),
            SeedVaccine(id: nil, name: "Yellow Fever", recommendedAgeInWeeks: 60, sequence: 46, notes: "After 9 months"),
            SeedVaccine(id: nil, name: "PPSV", recommendedAgeInWeeks: y(2), sequence: 47, notes: "After 2 years"),
            SeedVaccine(id: nil, name: "Rabies (any age)", recommendedAgeInWeeks: 0, sequence: 48, notes: "Any age as per exposure")
        ]
    }

    struct SeedVaccine { let id: UUID?; let name: String; let recommendedAgeInWeeks: Int; let sequence: Int?; let notes: String? }
}

private extension Comparable {
    func clamped(min: Self) -> Self { self < min ? min : self }
}


