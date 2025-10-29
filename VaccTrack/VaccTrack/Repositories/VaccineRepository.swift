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
            // At Birth
            SeedVaccine(id: nil, name: "BCG", recommendedAgeInWeeks: 0, sequence: 0, notes: "At Birth"),
            SeedVaccine(id: nil, name: "OPV", recommendedAgeInWeeks: 0, sequence: 1, notes: "At Birth"),
            SeedVaccine(id: nil, name: "Hepatitis B-1", recommendedAgeInWeeks: 0, sequence: 2, notes: "At Birth"),

            // 6 Weeks
            SeedVaccine(id: nil, name: "DTwP / DTaP-1", recommendedAgeInWeeks: 6, sequence: 3, notes: nil),
            SeedVaccine(id: nil, name: "IPV-1", recommendedAgeInWeeks: 6, sequence: 4, notes: nil),
            SeedVaccine(id: nil, name: "Hepatitis B-2", recommendedAgeInWeeks: 6, sequence: 5, notes: nil),
            SeedVaccine(id: nil, name: "Hib-1", recommendedAgeInWeeks: 6, sequence: 6, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-1", recommendedAgeInWeeks: 6, sequence: 7, notes: nil),
            SeedVaccine(id: nil, name: "PCV-1", recommendedAgeInWeeks: 6, sequence: 8, notes: nil),

            // 10 Weeks
            SeedVaccine(id: nil, name: "DTwP / DTaP-2", recommendedAgeInWeeks: 10, sequence: 9, notes: nil),
            SeedVaccine(id: nil, name: "IPV-2", recommendedAgeInWeeks: 10, sequence: 10, notes: nil),
            SeedVaccine(id: nil, name: "Hepatitis B-3", recommendedAgeInWeeks: 10, sequence: 11, notes: nil),
            SeedVaccine(id: nil, name: "Hib-2", recommendedAgeInWeeks: 10, sequence: 12, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-2", recommendedAgeInWeeks: 10, sequence: 13, notes: nil),
            SeedVaccine(id: nil, name: "PCV-2", recommendedAgeInWeeks: 10, sequence: 14, notes: nil),

            // 14 Weeks
            SeedVaccine(id: nil, name: "DTwP / DTaP-3", recommendedAgeInWeeks: 14, sequence: 15, notes: nil),
            SeedVaccine(id: nil, name: "IPV-3", recommendedAgeInWeeks: 14, sequence: 16, notes: nil),
            SeedVaccine(id: nil, name: "Hepatitis B-4", recommendedAgeInWeeks: 14, sequence: 17, notes: nil),
            SeedVaccine(id: nil, name: "Hib-3", recommendedAgeInWeeks: 14, sequence: 18, notes: nil),
            SeedVaccine(id: nil, name: "Rotavirus-3", recommendedAgeInWeeks: 14, sequence: 19, notes: nil),
            SeedVaccine(id: nil, name: "PCV-3", recommendedAgeInWeeks: 14, sequence: 20, notes: nil),

            // 6–7 Months
            SeedVaccine(id: nil, name: "Influenza-1", recommendedAgeInWeeks: m(6), sequence: 21, notes: "6 months"),
            SeedVaccine(id: nil, name: "Influenza-2", recommendedAgeInWeeks: m(7), sequence: 22, notes: "7 months"),

            // 6–9 Months
            SeedVaccine(id: nil, name: "TCV (Typhoid Conjugate Vaccine)", recommendedAgeInWeeks: m(8), sequence: 23, notes: "6–9 months"),

            // 9–13 Months series
            SeedVaccine(id: nil, name: "MMR-1", recommendedAgeInWeeks: m(9), sequence: 24, notes: "9 months"),
            SeedVaccine(id: nil, name: "MCV-1 (Meningococcal Vaccine 1)", recommendedAgeInWeeks: m(9), sequence: 25, notes: nil),
            SeedVaccine(id: nil, name: "Hepatitis A-1", recommendedAgeInWeeks: m(12), sequence: 26, notes: "12 months"),
            SeedVaccine(id: nil, name: "MMR-2", recommendedAgeInWeeks: m(12), sequence: 27, notes: nil),
            SeedVaccine(id: nil, name: "Varicella-1", recommendedAgeInWeeks: m(12), sequence: 28, notes: nil),
            SeedVaccine(id: nil, name: "JE-1 (Japanese Encephalitis 1)", recommendedAgeInWeeks: m(12), sequence: 29, notes: nil),
            SeedVaccine(id: nil, name: "Cholera-1", recommendedAgeInWeeks: m(12), sequence: 30, notes: nil),
            SeedVaccine(id: nil, name: "JE-2 (Japanese Encephalitis 2)", recommendedAgeInWeeks: m(13), sequence: 31, notes: nil),
            SeedVaccine(id: nil, name: "Cholera-2", recommendedAgeInWeeks: m(13), sequence: 32, notes: nil),

            // 15 Months
            SeedVaccine(id: nil, name: "PCV Booster (PCV-B)", recommendedAgeInWeeks: m(15), sequence: 33, notes: nil),
            // MCV-2 is at 12 Months per VaccineDB.json (not 15 months)
            SeedVaccine(id: nil, name: "MCV-2 (Meningococcal Vaccine 2)", recommendedAgeInWeeks: m(12), sequence: 34, notes: nil),

            // 16–18 Months
            SeedVaccine(id: nil, name: "DTwP / DTaP-B1", recommendedAgeInWeeks: m(16), sequence: 35, notes: nil),
            SeedVaccine(id: nil, name: "IPV-B1", recommendedAgeInWeeks: m(16), sequence: 36, notes: nil),
            SeedVaccine(id: nil, name: "Hib-B1", recommendedAgeInWeeks: m(16), sequence: 37, notes: nil),

            // 18–19 Months
            SeedVaccine(id: nil, name: "Hepatitis A-2", recommendedAgeInWeeks: m(18), sequence: 38, notes: nil),
            SeedVaccine(id: nil, name: "Varicella-2", recommendedAgeInWeeks: m(18), sequence: 39, notes: nil),

            // 2–3 Years
            SeedVaccine(id: nil, name: "Influenza", recommendedAgeInWeeks: y(2), sequence: 40, notes: "2–3 Years"),
            // 3–4 Years
            SeedVaccine(id: nil, name: "Influenza", recommendedAgeInWeeks: y(3), sequence: 41, notes: "3–4 Years"),
            // 4–5 Years
            SeedVaccine(id: nil, name: "Influenza", recommendedAgeInWeeks: y(4), sequence: 42, notes: "4–5 Years"),

            // 4–6 Years
            SeedVaccine(id: nil, name: "DTwP / DTaP-B2", recommendedAgeInWeeks: y(5), sequence: 43, notes: nil),
            SeedVaccine(id: nil, name: "IPV-B2", recommendedAgeInWeeks: y(5), sequence: 44, notes: nil),
            SeedVaccine(id: nil, name: "MMR-3", recommendedAgeInWeeks: y(5), sequence: 45, notes: nil),

            SeedVaccine(id: nil, name: "PPSV (Pneumococcal Polysaccharide Vaccine)", recommendedAgeInWeeks: y(2), sequence: 46, notes: "After 2 years"),

            // 9–14 Years
            SeedVaccine(id: nil, name: "Tdap", recommendedAgeInWeeks: y(9), sequence: 47, notes: nil),
            SeedVaccine(id: nil, name: "HPV-1", recommendedAgeInWeeks: y(9), sequence: 48, notes: nil),
            SeedVaccine(id: nil, name: "HPV-2", recommendedAgeInWeeks: y(9) + 26, sequence: 49, notes: nil),

            // After 9 Months / Any Age
            SeedVaccine(id: nil, name: "Yellow Fever (for travelers/high-risk regions)", recommendedAgeInWeeks: m(10), sequence: 50, notes: nil),
            SeedVaccine(id: nil, name: "Rabies (post-exposure or pre-exposure in high-risk area)", recommendedAgeInWeeks: 0, sequence: 51, notes: nil)
        ]
    }

    struct SeedVaccine { let id: UUID?; let name: String; let recommendedAgeInWeeks: Int; let sequence: Int?; let notes: String? }
}

private extension Comparable {
    func clamped(min: Self) -> Self { self < min ? min : self }
}


