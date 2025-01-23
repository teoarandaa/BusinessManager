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
        
        // Si ya está autenticado, no hacer nada
        guard !isAuthenticated else { return }
        
        if isBiometricEnabled && context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: "biometric_usage_description".localized()) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isAuthenticated = true
                        }
                    } else {
                        errorMessage = authenticationError?.localizedDescription ?? "Authentication failed"
                        showError = true
                    }
                }
            }
        } else {
            // Si la biometría no está habilitada o no está disponible, autenticar directamente
            isAuthenticated = true
        }
    }
    
    var body: some View {
        Color.clear
            .task {
                // Usar task en lugar de onAppear
                authenticate()
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