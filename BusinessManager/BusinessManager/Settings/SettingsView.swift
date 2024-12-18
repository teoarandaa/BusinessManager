import SwiftUI

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Sections for every setting
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section("Notifications") {
                    Toggle(isOn: $isPushEnabled) {
                        Label {
                            Text("Push notifications")
                        } icon: {
                            Image(systemName: isPushEnabled ? "bell" : "bell.slash")
                                .symbolEffect(.bounce, value: isPushEnabled)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
                // MARK: - Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $colorScheme) {
                        Label("System", systemImage: "iphone")
                            .tag(0)
                        Label("Light", systemImage: "sun.max")
                            .tag(1)
                        Label("Dark", systemImage: "moon")
                            .tag(2)
                    }
                    .pickerStyle(.navigationLink)
                }
                // MARK: - Plans
                Section("Pricing") {
                    NavigationLink(destination: PlansView()) {
                        Label("Subscription packages", systemImage: "creditcard")
                    }
                }
                // MARK: - Resources
                Section("Resources") {
                    NavigationLink(destination: FaqView()) {
                        Label("FAQ", systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy", systemImage: "lock")
                    }
                    Button(action: {
                        sendEmail(to: "help.businessmanager@gmail.com")
                    }) {
                        Label("Business Manager support", systemImage: "envelope")
                    }
                }
                // MARK: - Reports
                Section("Reports") {
                    NavigationLink(destination: MonthlyReportView()) {
                        Label("Monthly Summary (PDF)", systemImage: "text.document")
                    }
                }
            }
            Text("Version \(appVersion!)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(colorSchemeValue)
    }
    
    private var colorSchemeValue: ColorScheme? {
        switch colorScheme {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil // System default
        }
    }
    
    func sendEmail(to address: String) {
        if let url = URL(string: "mailto:\(address)") {
            UIApplication.shared.open(url)
        }
    }
    
    // Añadir haptic feedback para acciones importantes
    func performHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Shows the current version
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

#Preview {
    SettingsView()
}
