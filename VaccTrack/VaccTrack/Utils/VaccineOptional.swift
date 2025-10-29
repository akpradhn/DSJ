import Foundation

enum VaccineOptionalHelper {
    // Canonical optional vaccine names
    private static let optionalNames: Set<String> = [
        "MCV-1 (Meningococcal Vaccine 1)",
        "MCV-2 (Meningococcal Vaccine 2)",
        "JE-1 (Japanese Encephalitis 1)",
        "JE-2 (Japanese Encephalitis 2)",
        "Cholera-1",
        "Cholera-2"
    ].map { $0.lowercased() }.reduce(into: Set<String>()) { $0.insert($1) }

    static func isOptional(name: String?) -> Bool {
        guard let n = name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty else { return false }
        return optionalNames.contains(n)
    }
}


