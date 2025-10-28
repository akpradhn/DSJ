import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var notificationsEnabled = false
    @State private var showingImporter = false
    @State private var exportURL: URL?

    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            NotificationHelper.requestPermission()
                        }
                    }
                Button("Schedule sample reminder in 10s") {
                    NotificationHelper.scheduleSample()
                }
            }
            Section(header: Text("Data")) {
                Button("Export All (JSON)") { exportAll() }
                if let url = exportURL {
                    ShareLink(item: url) {
                        Label("Share Export", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Import JSON") { showingImporter = true }
            }
            Section(header: Text("Backup / Restore")) {
                Text("Use Export to save to Files, and Import to restore.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Section(header: Text("About")) {
                Text("VaccTrack helps track vaccination schedules for babies/patients. Data is stored locally on your device.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(Text("Settings"))
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                do {
                    try ExportImportService.importJSON(from: url, context: context)
                } catch {
                }
            case .failure:
                break
            }
        }
    }

    private func exportAll() {
        do {
            let data = try ExportImportService.exportAllPatientsJSON(context: context)
            exportURL = data.tempFileURL(filename: "VaccTrack-Backup.json")
        } catch {
        }
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


