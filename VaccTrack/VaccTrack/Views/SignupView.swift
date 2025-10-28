import SwiftUI

struct SignupView: View {
    @ObservedObject private var auth = AuthManager.shared

    @State private var phone: String = ""
    @State private var otp: String = ""
    @State private var sent = false
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [.purple.opacity(0.25), .purple.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 220)
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                HStack(spacing: 12) {
                    Branding.appLogo.resizable().scaledToFit().frame(width: 28, height: 28)
                    VStack(alignment: .leading) {
                        Text(Branding.appName).font(.headline)
                        Text("Create your account").font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 24)
                .padding(.bottom, 24)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Sign Up").font(.title.bold()).padding(.top, 16)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Phone").font(.caption).foregroundColor(.secondary)
                    TextField("e.g. +91 98765 43210", text: $phone)
                        .keyboardType(.phonePad)
                        .padding(.vertical, 10)
                        .overlay(Rectangle().frame(height: 1).offset(y: 12).foregroundColor(.secondary.opacity(0.3)), alignment: .bottom)
                }

                if sent {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("OTP").font(.caption).foregroundColor(.secondary)
                        TextField("6-digit code", text: $otp)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .overlay(Rectangle().frame(height: 1).offset(y: 12).foregroundColor(.secondary.opacity(0.3)), alignment: .bottom)
                    }
                    .transition(.opacity)
                }

                if let error = error { Text(error).foregroundColor(.red).font(.footnote) }

                Button(action: action) {
                    HStack { Spacer(); if isLoading { ProgressView() } else { Text(sent ? "Create Account" : "Send OTP") }; Spacer() }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                .foregroundColor(.white)
                .disabled(phone.trimmingCharacters(in: .whitespaces).isEmpty || (sent && otp.isEmpty) || isLoading)
                .padding(.top, 4)

                HStack(spacing: 4) {
                    Text("Already have an account?")
                    Button("Login") { NotificationCenter.default.post(name: .toggleAuthMode, object: nil) }
                }
                .font(.footnote)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
    }

    private func action() {
        error = nil
        if !sent {
            isLoading = true
            auth.requestOTP(for: phone) { result in
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
}
