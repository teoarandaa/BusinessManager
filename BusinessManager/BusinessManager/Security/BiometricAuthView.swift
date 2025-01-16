import SwiftUI
import LocalAuthentication

struct BiometricAuthView: View {
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled = false
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isAuthenticated: Bool
    @State private var showError = false
    @State private var errorMessage = ""
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "biometric_usage_description".localized()) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                    } else {
                        errorMessage = authenticationError?.localizedDescription ?? "Authentication failed"
                        showError = true
                    }
                }
            }
        } else {
            errorMessage = error?.localizedDescription ?? "Biometric authentication not available"
            showError = true
        }
    }
    
    var body: some View {
        Color(colorScheme == .dark ? .black : .white)
            .ignoresSafeArea()
            .onAppear {
                if isBiometricEnabled {
                    authenticate()
                } else {
                    isAuthenticated = true
                }
            }
            .alert("authentication_error".localized(), isPresented: $showError) {
                Button("ok".localized(), role: .cancel) {
                    authenticate()
                }
            } message: {
                Text(errorMessage)
            }
    }
} 