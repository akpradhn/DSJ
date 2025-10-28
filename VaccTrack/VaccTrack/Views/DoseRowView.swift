import SwiftUI

struct DoseRowView: View {
    let dose: Dose

    var body: some View {
        NavigationLink {
            DoseDetailView(dose: dose)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dose.vaccine?.name ?? "Vaccine")
                        .font(.body)
                    Text(DateHelpers.formatDate(dose.scheduledDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                statusBadge
            }
            .contentShape(Rectangle())
        }
    }

    private var statusBadge: some View {
        let status = dose.status
        return HStack(spacing: 6) {
            Image(systemName: status.iconName)
            switch status {
            case .given(let date):
                Text(DateHelpers.shortDate(date))
            case .upcoming(let days):
                Text(String(format: NSLocalizedString("%d days", comment: ""), days))
            case .overdue(let days):
                Text(String(format: NSLocalizedString("%d overdue", comment: ""), days))
            case .notGiven:
                Text(NSLocalizedString("Not given", comment: ""))
            }
        }
        .font(.caption2)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Capsule().fill(status.color.opacity(0.2)))
        .foregroundColor(status.color)
    }
}


