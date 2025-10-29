import SwiftUI
import CoreData
import UserNotifications
import UIKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var notificationsEnabled = false
    @State private var showShare = false
    @State private var exportData: Data? = nil
    @State private var showResetConfirm = false
    @State private var isResetting = false
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var showBackupError = false
    @State private var backupErrorMessage = ""
    @State private var showRestoreConfirm = false
    @State private var showBackupSuccess = false
    @State private var showRestoreSuccess = false
    @State private var restoreBackupDate: Date?
    @State private var hasBackup = BackupService.hasBackup

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
            Section(header: Text("Backup & Restore")) {
                // Backup section
                if isBackingUp {
                    HStack {
                        ProgressView()
                        Text("Creating backup...")
                    }
                } else {
                    Button("Create Backup") {
                        Task {
                            await createBackup()
                        }
                    }
                }
                if let last = BackupService.lastBackupDate {
                    Text("Last backup: \(DateHelpers.formatDateTime(last))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Restore section
                if hasBackup {
                    if isRestoring {
                        HStack {
                            ProgressView()
                            Text("Restoring from backup...")
                        }
                    } else {
                        Button("Restore from Backup") {
                            showRestoreConfirm = true
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    HStack {
                        Text("Restore from Backup")
                        Spacer()
                        Text("No backup available")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .disabled(true)
                }
            }
            Section(header: Text("Data")) {
                if isResetting {
                    HStack {
                        ProgressView()
                        Text("Resetting database...")
                    }
                } else {
                    Button("Reset Database") { showResetConfirm = true }
                        .foregroundColor(.red)
                }
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
        .alert("Reset Database?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) { Task { await resetDatabase() } }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all patients and doses, then reseed vaccines. This action cannot be undone.")
        }
        .alert("Restore from Backup?", isPresented: $showRestoreConfirm) {
            Button("Restore", role: .destructive) { Task { await restoreBackup() } }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let backupDate = BackupService.lastBackupDate {
                Text("This will restore the complete snapshot from \(DateHelpers.formatDateTime(backupDate)). All current data will be replaced.")
            } else {
                Text("This will restore the complete snapshot from backup. All current data will be replaced.")
            }
        }
        .alert("Backup Created", isPresented: $showBackupSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            if let backupDate = BackupService.lastBackupDate {
                Text("Backup created successfully at \(DateHelpers.formatDateTime(backupDate)).")
            } else {
                Text("Backup created successfully.")
            }
        }
        .alert("Backup Restored", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            if let date = restoreBackupDate {
                Text("Backup restored successfully. Snapshot from \(DateHelpers.formatDateTime(date)) has been restored.")
            } else {
                Text("Backup restored successfully.")
            }
        }
        .alert("Backup Error", isPresented: $showBackupError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(backupErrorMessage)
        }
        .onAppear {
            hasBackup = BackupService.hasBackup
        }
    }

    private func exportPDF() {
        // Export for the first patient for now (can be extended to picker later)
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.fetchLimit = 1
        if let patient = try? context.fetch(request).first {
            exportData = PDFGenerator.generateCardLikePDF(patient: patient)
        }
    }

    private func resetDatabase() async {
        guard !isResetting else { return }
        await MainActor.run { isResetting = true }

        do {
            try await context.perform {
                // Batch delete order: doses -> patients -> vaccines
                let doseReq: NSFetchRequest<NSFetchRequestResult> = Dose.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>
                let patientReq: NSFetchRequest<NSFetchRequestResult> = Patient.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>
                let vaccineReq: NSFetchRequest<NSFetchRequestResult> = Vaccine.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>

                for request in [doseReq, patientReq, vaccineReq] {
                    let delete = NSBatchDeleteRequest(fetchRequest: request)
                    delete.resultType = .resultTypeObjectIDs
                    if let result = try? context.execute(delete) as? NSBatchDeleteResult,
                       let ids = result.result as? [NSManagedObjectID] {
                        let changes = [NSDeletedObjectsKey: ids]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                    }
                }
                try context.save()
            }

            // Reseed vaccines
            await VaccineRepository.seedVaccinesIfNeeded(context: context)
        } catch {
            print("Reset DB failed: \(error)")
        }

        await MainActor.run { isResetting = false }
    }
    
    private func createBackup() async {
        guard !isBackingUp else { return }
        await MainActor.run { isBackingUp = true }
        
        do {
            try BackupService.createBackup(context: context)
            await MainActor.run {
                hasBackup = true
                isBackingUp = false
                showBackupSuccess = true
            }
        } catch {
            await MainActor.run {
                backupErrorMessage = "Failed to create backup: \(error.localizedDescription)"
                showBackupError = true
                isBackingUp = false
            }
        }
    }
    
    private func restoreBackup() async {
        guard !isRestoring, BackupService.hasBackup else { return }
        await MainActor.run { isRestoring = true }
        
        do {
            let backupDate = try BackupService.restoreBackup(context: context)
            await MainActor.run {
                restoreBackupDate = backupDate
                isRestoring = false
                showRestoreSuccess = true
            }
        } catch {
            await MainActor.run {
                backupErrorMessage = "Failed to restore backup: \(error.localizedDescription)"
                showBackupError = true
                isRestoring = false
            }
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


