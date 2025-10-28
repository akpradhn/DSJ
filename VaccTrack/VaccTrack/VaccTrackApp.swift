import SwiftUI
import UserNotifications
import CoreData
import Combine

@main
struct VaccTrackApp: App {
    private let persistenceController = PersistenceController.shared
    @StateObject private var notificationCenterDelegate = NotificationCenterDelegate()
    @ObservedObject private var auth = AuthManager.shared

    @Environment(\.scenePhase) private var scenePhase
    @State private var deepLinkPatientID: UUID?

    init() { UNUserNotificationCenter.current().delegate = notificationCenterDelegate }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated { HomeView() } else { AuthContainerView() }
            }
            .environment(\.managedObjectContext, persistenceController.viewContext)
            .environmentObject(notificationCenterDelegate)
            .onChange(of: notificationCenterDelegate.pendingPatientID) { _, patientID in
                deepLinkPatientID = patientID
            }
            .onAppear { Task { await VaccineRepository.seedVaccinesIfNeeded(context: persistenceController.viewContext) } }
        }
        .onChange(of: scenePhase) { _, phase in if phase == .background { persistenceController.save() } }
    }
}

final class NotificationCenterDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var pendingPatientID: UUID?
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let patientIdString = response.notification.request.content.userInfo["patientID"] as? String, let uuid = UUID(uuidString: patientIdString) { DispatchQueue.main.async { self.pendingPatientID = uuid } }
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { completionHandler([.banner, .badge, .sound]) }
}


