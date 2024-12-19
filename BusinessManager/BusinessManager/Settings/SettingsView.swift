import SwiftUI

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var forceUpdate = false
    
    private var effectiveColorScheme: ColorScheme {
        switch colorScheme {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return systemColorScheme
        }
    }
    
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
                    HStack {
                        Label {
                            NavigationLink {
                                ThemePickerView(selection: $colorScheme)
                            } label: {
                                HStack {
                                    Text("Theme")
                                    Spacer()
                                    Text(colorScheme == 0 ? "System" : 
                                         colorScheme == 1 ? "Light" : "Dark")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "paintbrush")
                        }
                    }
                    .onChange(of: colorScheme) { oldValue, newValue in
                        forceUpdate.toggle()
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
        .environment(\.colorScheme, effectiveColorScheme)
        .id(forceUpdate)
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
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

struct ThemePickerView: View {
    @Binding var selection: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Label("System", systemImage: "iphone")
                .onTapGesture { 
                    selection = 0
                    dismiss()
                }
            Label("Light", systemImage: "sun.max")
                .onTapGesture { 
                    selection = 1
                    dismiss()
                }
            Label("Dark", systemImage: "moon")
                .onTapGesture { 
                    selection = 2
                    dismiss()
                }
        }
        .navigationTitle("Theme")
    }
}

#Preview {
    SettingsView()
}
