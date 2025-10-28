import Foundation
import Combine

struct AuthTokens: Codable { let access: String; let refresh: String; let expiry: Date }

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published private(set) var isAuthenticated: Bool
    @Published var phoneNumber: String = ""
    @Published var email: String = ""

    var hasUser: Bool { UserDefaults.standard.bool(forKey: "auth_hasUser") }

    private init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "auth_isAuthenticated")
        // If tokens exist and valid, ensure auth
        if let tokens = loadTokens(), tokens.expiry > Date() {
            self.isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "auth_isAuthenticated")
        }
    }

    func signOut() {
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "auth_isAuthenticated")
        saveTokens(nil)
    }

    func registerIfNeeded() {
        if !hasUser { UserDefaults.standard.set(true, forKey: "auth_hasUser") }
    }

    func requestOTP(for phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        phoneNumber = phone
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { completion(.success(())) }
    }

    func verifyOTP(_ code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Accept any 6-digit code in mock
        guard code.count >= 4 else {
            completion(.failure(NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid code"]))); return
        }
        // Issue short-lived access (2 minutes) + refresh (1 day)
        let tokens = AuthTokens(access: UUID().uuidString, refresh: UUID().uuidString, expiry: Date().addingTimeInterval(120))
        saveTokens(tokens)
        isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "auth_isAuthenticated")
        registerIfNeeded()
        completion(.success(()))
    }

    func ensureValidAccess(completion: @escaping (String?) -> Void) {
        if var t = loadTokens() {
            if t.expiry > Date() {
                completion(t.access)
            } else {
                // Mock refresh: create new access and extend expiry
                t = AuthTokens(access: UUID().uuidString, refresh: t.refresh, expiry: Date().addingTimeInterval(120))
                saveTokens(t)
                completion(t.access)
            }
        } else {
            completion(nil)
        }
    }

    private func saveTokens(_ tokens: AuthTokens?) {
        if let tokens = tokens, let data = try? JSONEncoder().encode(tokens) {
            KeychainStore.set(String(data: data, encoding: .utf8) ?? "", for: "auth_tokens")
        } else {
            KeychainStore.delete("auth_tokens")
        }
    }

    private func loadTokens() -> AuthTokens? {
        guard let s = KeychainStore.get("auth_tokens"), let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AuthTokens.self, from: data)
    }
}
