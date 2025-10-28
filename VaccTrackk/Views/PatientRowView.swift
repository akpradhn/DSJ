import SwiftUI

struct PatientRowView: View {
    let patient: Patient

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.displayName)
                    .font(.headline)
                Text(DateHelpers.formatDate(patient.dob))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let next = patient.nextDueDate {
                VStack(alignment: .trailing) {
                    Text("Next")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(DateHelpers.relativeDays(to: next))
                        .font(.caption2)
                        .padding(4)
                        .background(Capsule().fill(Color.yellow.opacity(0.2)))
                }
            }
        }
        .contentShape(Rectangle())
    }
}


