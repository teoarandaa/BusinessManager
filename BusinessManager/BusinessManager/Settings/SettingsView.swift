import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    
    // MARK: - Sections for every setting
    var body: some View {
        NavigationView {
            List {
                // MARK: - Notifications
                Section("Notifications") {
                    Toggle(isOn: $isPushEnabled) {
                        Label {
                            Text("Push notifications")
                        } icon: {
                            Image(systemName: isPushEnabled ? "bell.slash" : "bell")
                                .symbolEffect(.bounce, value: isPushEnabled)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
                // MARK: - Appearance
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label {
                            Text(isDarkMode ? "Light mode" : "Dark mode")
                        } icon: {
                            Image(systemName: isDarkMode ? "lightbulb" : "lightbulb.slash")
                                .symbolEffect(.bounce, value: isDarkMode)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
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
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    func sendEmail(to address: String) {
        if let url = URL(string: "mailto:\(address)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}
