import Foundation

struct VaccineDB: Decodable {
    let RecommendedVaccinationRecord: [String: [String]]
    let OptionalVaccinationRecord: [String: [String]]
}

enum VaccineDBLoader {
    // Ordered keys as they appear in the attached JSON
    static let normalOrder: [String] = [
        "AtBirth", "6Weeks", "10Weeks", "14Weeks",
        "6Months", "7Months", "6to9Months", "9Months",
        "12Months", "15Months", "16to18Months", "18to19Months",
        "2to3Years", "3to4Years", "4to5Years", "4to6Years",
        "10to14Years"
    ]
    static let optionalOrder: [String] = [
        "9Month", "12Month", "13Month", "After 9Month", "After 2years", "AnyAge"
    ]

    static func load() -> VaccineDB? {
        guard let url = Bundle.main.url(forResource: "VaccineDB", withExtension: "json") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let db = try JSONDecoder().decode(VaccineDB.self, from: data)
            return db
        } catch {
            print("Failed to load VaccineDB.json: \(error)")
            return nil
        }
    }
}


