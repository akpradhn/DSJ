import SwiftUI

struct AgeGroupSelectView: View {
    let buckets: [(label: String, weeks: Int)]
    @Binding var selectionWeeks: Int
    @State private var query: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(filtered, id: \.weeks) { item in
            Button(action: { selectionWeeks = item.weeks; dismiss() }) {
                HStack {
                    Text(item.label)
                    Spacer()
                    if selectionWeeks == item.weeks { Image(systemName: "checkmark") }
                }
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Age Group")
    }

    private var filtered: [(label: String, weeks: Int)] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return buckets }
        let q = query.lowercased()
        return buckets.filter { $0.label.lowercased().contains(q) }
    }
}


