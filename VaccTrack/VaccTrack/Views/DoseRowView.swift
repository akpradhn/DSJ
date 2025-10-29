import SwiftUI
import CoreData

struct DoseRowView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var dose: Dose

    var body: some View {
        Group {
            if dose.managedObjectContext == nil || dose.isDeleted {
                EmptyView()
            } else {
                NavigationLink {
                    DoseDetailView(dose: dose)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(dose.vaccine?.name ?? "Vaccine")
                                    .font(.body)
                                if VaccineOptionalHelper.isOptional(name: dose.vaccine?.name) {
                                    Text("Optional")
                                        .font(.caption2)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 6)
                                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                                        .foregroundColor(.blue)
                                }
                            }
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


