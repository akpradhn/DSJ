import SwiftUI

struct LoginView: View {
    @ObservedObject private var auth = AuthManager.shared

    @State private var phone: String = ""
    @State private var otp: String = ""
    @State private var sent = false
    @State private var isLoading = false
    @State private var error: String?

    // Forgot alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Country codes (basic list)
    struct Country: Identifiable, Hashable { let id = UUID(); let name: String; let flag: String; let dial: String; let minDigits: Int; let maxDigits: Int }
    private let countries: [Country] = [
        Country(name: "India", flag: "🇮🇳", dial: "+91", minDigits: 10, maxDigits: 10),
        Country(name: "United States", flag: "🇺🇸", dial: "+1", minDigits: 10, maxDigits: 10),
        Country(name: "United Kingdom", flag: "🇬🇧", dial: "+44", minDigits: 9, maxDigits: 10),
        Country(name: "Australia", flag: "🇦🇺", dial: "+61", minDigits: 9, maxDigits: 9),
        Country(name: "Canada", flag: "🇨🇦", dial: "+1", minDigits: 10, maxDigits: 10)
    ]
    @State private var selectedCountryIndex: Int = 0 // default India

    var body: some View {
        VStack(spacing: 0) {
            // Decorative header
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [Color("LoginTop") ?? .blue.opacity(0.25), Color("LoginTop2") ?? .blue.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 180)
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                VStack(spacing: 4) {
                    Branding.appLogo.resizable().scaledToFit().frame(width: 36, height: 36)
                    Text(Branding.appName)
                        .font(.system(size: 28, weight: .bold))
                    Text("Find your health").font(.caption).foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Login").font(.title.bold()).padding(.top, 16)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Phone").font(.caption).foregroundColor(.secondary)
                    HStack {
                        Menu {
                            Picker("Country", selection: $selectedCountryIndex) {
                                ForEach(Array(countries.enumerated()), id: \.offset) { idx, c in
                                    Text("\(c.flag) \(c.name) \(c.dial)").tag(idx)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) { Text(countries[selectedCountryIndex].flag); Text(countries[selectedCountryIndex].dial).font(.body.bold()) }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(.secondarySystemBackground)))
                        }
                        TextField("e.g. 98765 43210", text: $phone)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }
                    Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                    HStack {
                        Spacer()
                        Button("Forgot?") { forgotAction() }
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let error = validationMessage { Text(error).foregroundColor(.red).font(.footnote) }

                // OTP BETWEEN PHONE AND BUTTON
                if sent {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("OTP").font(.caption).foregroundColor(.secondary)
                        TextField("6-digit code", text: $otp)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .overlay(Rectangle().frame(height: 1).offset(y: 12).foregroundColor(.secondary.opacity(0.3)), alignment: .bottom)
                    }
                }

                Button(action: action) {
                    HStack { Spacer(); if isLoading { ProgressView() } else { Text(sent ? "Log In" : "Send OTP") }; Spacer() }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.85)))
                .foregroundColor(.white)
                .disabled(!isPhoneValid || (sent && otp.isEmpty) || isLoading)
                .padding(.top, 4)

                Spacer(minLength: 24)

                HStack(spacing: 6) {
                    Text("Don't have account?")
                    Button("Create now") { NotificationCenter.default.post(name: .toggleAuthMode, object: nil) }
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .alert(alertMessage, isPresented: $showAlert) { Button("OK", role: .cancel) {} }

            Spacer(minLength: 0)
        }
    }

    private var isPhoneValid: Bool {
        let digits = phone.filter { $0.isNumber }
        let c = countries[selectedCountryIndex]
        return digits.count >= c.minDigits && digits.count <= c.maxDigits
    }

    private var validationMessage: String? {
        if phone.isEmpty { return nil }
        return isPhoneValid ? nil : "Enter a valid phone number for \(countries[selectedCountryIndex].dial)"
    }

    private func action() {
        error = nil
        let c = countries[selectedCountryIndex]
        let normalized = c.dial + phone.filter { $0.isNumber }
        if !sent {
            guard isPhoneValid else { return }
            isLoading = true
            auth.requestOTP(for: normalized) { result in
                isLoading = false
                switch result { case .success: withAnimation { sent = true }; case .failure(let err): error = err.localizedDescription }
            }
        } else {
            isLoading = true
            auth.verifyOTP(otp) { result in
                isLoading = false
                if case .failure(let err) = result { error = err.localizedDescription }
            }
        }
    }

    private func forgotAction() {
        let c = countries[selectedCountryIndex]
        let normalized = c.dial + phone.filter { $0.isNumber }
        guard isPhoneValid else {
            alertMessage = "Enter a valid phone number to receive OTP."
            showAlert = true
            return
        }
        isLoading = true
        auth.requestOTP(for: normalized) { result in
            isLoading = false
            switch result {
            case .success:
                withAnimation { sent = true }
                alertMessage = "OTP has been sent to your number."
                showAlert = true
            case .failure(let err):
                alertMessage = err.localizedDescription
                showAlert = true
            }
        }
    }
}

// RoundedCorner helper at bottom remains unchanged
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Notification.Name { static let toggleAuthMode = Notification.Name("toggleAuthMode") }
