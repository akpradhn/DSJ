import SwiftUI

struct AuthContainerView: View {
    @ObservedObject private var auth = AuthManager.shared
    @State private var showSignup: Bool = !AuthManager.shared.hasUser

    var body: some View {
        ZStack {
            if showSignup { SignupView() } else { LoginView() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleAuthMode)) { _ in
            withAnimation { showSignup.toggle() }
        }
    }
}
