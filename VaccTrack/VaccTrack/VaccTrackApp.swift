import SwiftUI
import UserNotifications
import CoreData
import Combine

@main
struct VaccTrackApp: App {
    private let persistenceController = PersistenceController.shared
    @ObservedObject private var auth = AuthManager.shared

    @Environment(\.scenePhase) private var scenePhase
    @State private var deepLinkPatientID: UUID?
    @State private var isLaunching: Bool = true

    init() {
        // Set delegate on app initialization (before StateObject is created)
        UNUserNotificationCenter.current().delegate = NotificationCenterDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if auth.isAuthenticated { HomeView() } else { AuthContainerView() }
                }
                if isLaunching {
                    Color(UIColor.systemBackground).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.2)
                        Text("Loading...").foregroundColor(.secondary)
                    }
                }
            }
            .environment(\.managedObjectContext, persistenceController.viewContext)
            .environmentObject(NotificationCenterDelegate.shared)
            .onChange(of: NotificationCenterDelegate.shared.pendingPatientID) { _, patientID in
                deepLinkPatientID = patientID
            }
            .task {
                // Perform any startup work while showing loader
                await VaccineRepository.seedVaccinesIfNeeded(context: persistenceController.viewContext)
                
                try? await Task.sleep(nanoseconds: 400_000_000) // brief polish
                withAnimation(.easeOut(duration: 0.25)) { isLaunching = false }
            }
        }
        .onChange(of: scenePhase) { _, phase in if phase == .background { persistenceController.save() } }
    }
}

final class NotificationCenterDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCenterDelegate()
    
    @Published var pendingPatientID: UUID?
    
    private override init() {
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let patientIdString = response.notification.request.content.userInfo["patientID"] as? String, let uuid = UUID(uuidString: patientIdString) { DispatchQueue.main.async { self.pendingPatientID = uuid } }
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { completionHandler([.banner, .badge, .sound]) }
}


