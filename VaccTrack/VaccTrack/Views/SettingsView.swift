import SwiftUI
import CoreData
import UserNotifications
import UIKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var notificationsEnabled = false
    @State private var showShare = false
    @State private var exportData: Data? = nil

    var body: some View {
        Form {
            Section(header: Text("Reports")) {
                Button("Export Vaccination Report (PDF)") { exportPDF() }
                    .accessibilityLabel(Text("Export report"))
            }
            Section(header: Text("Notifications")) {
                Toggle("Enable reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue { NotificationHelper.requestPermission() }
                    }
                Button("Schedule sample reminder in 10s") { NotificationHelper.scheduleSample() }
            }
            Section(header: Text("Privacy & About")) {
                Text("VaccTrack stores your data securely on-device using Core Data. No cloud uploads.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Section {
                Button("Sign Out") { AuthManager.shared.signOut() }
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: Binding(get: { exportData != nil }, set: { if !$0 { exportData = nil } })) {
            if let data = exportData {
                ShareSheet(activityItems: [TempFile.write(data: data, ext: "pdf").url])
            }
        }
        .navigationTitle(Text("Settings"))
    }

    private func exportPDF() {
        // Export for the first patient for now (can be extended to picker later)
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.fetchLimit = 1
        if let patient = try? context.fetch(request).first {
            exportData = PDFGenerator.generateCardLikePDF(patient: patient)
        }
    }
}

// Simple UIActivityViewController wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: activityItems, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Temporary file to share Data easily
enum TempFile {
    struct Handle { let url: URL }
    static func write(data: Data, ext: String) -> Handle {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
        try? data.write(to: url)
        return Handle(url: url)
    }
}

enum NotificationHelper {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func scheduleSample() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Upcoming Vaccine", comment: "")
        content.body = NSLocalizedString("A vaccine dose is due soon.", comment: "")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleReminder(for dose: Dose, leadDays: Int = 3) {
        guard let patient = dose.patient else { return }
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Upcoming Vaccine", comment: "")
        let dateStr = DateHelpers.formatDate(dose.scheduledDate)
        content.body = "\(patient.displayName): \(dose.vaccine?.name ?? "") on \(dateStr)"
        content.userInfo = ["patientID": patient.id.uuidString]
        content.sound = .default

        let remindDate = Calendar.current.date(byAdding: .day, value: -leadDays, to: dose.scheduledDate) ?? Date()
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: dose.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}


