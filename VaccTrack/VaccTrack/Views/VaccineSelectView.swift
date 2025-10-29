import SwiftUI
import CoreData

struct VaccineSelectView: View {
    let vaccines: [Vaccine]
    @Binding var selection: Vaccine?
    @State private var query: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(filteredVaccines, id: \.objectID) { v in
            Button(action: { selection = v; dismiss() }) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(v.name)
                        let weeks = Int(v.recommendedAgeInWeeks)
                        let band = bandLabel(for: weeks)
                        let subtitle = band != nil ? "\(band!) (Week \(weeks))" : "Week \(weeks)"
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if VaccineOptionalHelper.isOptional(name: v.name) {
                        Text("Optional")
                            .font(.caption2)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Capsule().fill(Color.blue.opacity(0.15)))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    if selection?.objectID == v.objectID { Image(systemName: "checkmark") }
                }
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Vaccine")
    }

    private var filteredVaccines: [Vaccine] {
        // Sort by name then age
        let sorted = vaccines.sorted { lhs, rhs in
            if lhs.name == rhs.name { return lhs.recommendedAgeInWeeks < rhs.recommendedAgeInWeeks }
            return lhs.sequence < rhs.sequence
        }
        // Group by name
        let groups = Dictionary(grouping: sorted, by: { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        var result: [Vaccine] = []
        for (_, arr) in groups {
            let banded = arr.compactMap { v -> (String, Vaccine)? in
                if let band = bandLabel(for: Int(v.recommendedAgeInWeeks)) { return (band, v) }
                return nil
            }
            if !banded.isEmpty {
                var seenBands = Set<String>()
                for (band, v) in banded.sorted(by: { $0.1.recommendedAgeInWeeks < $1.1.recommendedAgeInWeeks }) {
                    if !seenBands.contains(band) { seenBands.insert(band); result.append(v) }
                }
            } else {
                // no banded entries; dedupe by exact weeks
                var seenWeeks = Set<Int>()
                for v in arr {
                    let w = Int(v.recommendedAgeInWeeks)
                    if !seenWeeks.contains(w) { seenWeeks.insert(w); result.append(v) }
                }
            }
        }
        // Optional search filter supports name or age label
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return result }
        return result.filter {
            $0.name.lowercased().contains(q) || ageLabel(for: Int($0.recommendedAgeInWeeks)).lowercased().contains(q)
        }
    }

    private func ageLabel(for weeks: Int) -> String {
        switch weeks {
        case 0: return "At Birth"
        case 6: return "6 Weeks"
        case 10: return "10 Weeks"
        case 14: return "14 Weeks"
        case 26: return "6 Months"
        case 30: return "7 Months"
        case 35: return "6–9 Months"
        case 39: return "9 Months"
        case 52: return "12 Months"
        case 56: return "13 Months"
        case 65: return "15 Months"
        case 69: return "16–18 Months"
        case 78: return "18–19 Months"
        case 104: return "2–3 Years"
        case 156: return "3–4 Years"
        case 208: return "4–5 Years"
        case 260: return "4–6 Years"
        case 468: return "9–14 Years"
        default:
            if weeks % 52 == 0 { return "\(weeks/52) Years" }
            if weeks % 4 == 0 { return "\(weeks/4) Weeks" }
            return "Week \(weeks)"
        }
    }

    private func bandLabel(for weeks: Int) -> String? {
        let label = ageLabel(for: weeks)
        return label.hasPrefix("Week") ? nil : label
    }
}


