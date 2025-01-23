import SwiftUI
import SwiftData
import LocalAuthentication

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "es"
    @AppStorage("colorScheme") private var colorScheme = 0
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("iCloudSync") private var iCloudSync = false
    @Environment(\.modelContext) private var context
    @State private var isPushEnabled = false
    @State private var showLanguageAlert = false
    @State private var showNotificationSettingsAlert = false
    
    private let availableLanguages = [
        ("es", "Español"),
        ("en", "English"),
        ("pt", "Português"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("it", "Italiano")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Language
                Section("language".localized()) {
                    languageSection
                }
                
                // MARK: - Notifications
                Section("notifications".localized()) {
                    notificationsSection
                }
                
                // MARK: - Appearance & Security
                Section("appearance".localized()) {
                    appearanceSection
                }
                
                // MARK: - Support
                Section("support".localized()) {
                    supportSection
                }
                
                // MARK: - Reports
                Section("reports".localized()) {
                    reportsSection
                }
                
                // MARK: - Version
                versionSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings".localized())
        }
        .alert("language_change_title".localized(), isPresented: $showLanguageAlert) {
            languageAlertButtons
        } message: {
            Text("language_change_message".localized())
        }
        .alert("notifications_settings_title".localized(), isPresented: $showNotificationSettingsAlert) {
            notificationAlertButtons
        } message: {
            Text("notifications_settings_message".localized())
        }
        .onAppear {
            checkICloudStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
            checkICloudStatus()
        }
    }
    
    // MARK: - Section Views
    private var languageSection: some View {
        Label {
            Picker("select_language".localized(), selection: $appLanguage) {
                ForEach(availableLanguages, id: \.0) { language in
                    Text(language.1).tag(language.0)
                }
            }
        } icon: {
            Image(systemName: "globe")
        }
        .onChange(of: appLanguage) { _, _ in
            UserDefaults.standard.set([appLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            showLanguageAlert = true
        }
    }
    
    private var notificationsSection: some View {
        Toggle(isOn: $isPushEnabled) {
            Label {
                Text("push_notifications".localized())
            } icon: {
                Image(systemName: isPushEnabled ? "bell" : "bell.slash")
            }
        }
        .onChange(of: isPushEnabled) { _, _ in
            handleNotificationToggle()
        }
    }
    
    private var appearanceSection: some View {
        Group {
            NavigationLink {
                ThemePickerView(selection: $colorScheme)
            } label: {
                Label("theme".localized(), systemImage: "paintbrush")
            }
            
            Toggle(isOn: $isBiometricEnabled) {
                Label("biometric_authentication".localized(), systemImage: "faceid")
            }
        }
    }
    
    private var supportSection: some View {
        Group {
            NavigationLink(destination: LazyView(FaqView())) {
                Label("faq".localized(), systemImage: "questionmark.circle")
            }
            
            NavigationLink(destination: LazyView(PrivacyView())) {
                Label("privacy".localized(), systemImage: "lock.shield")
            }
            
            NavigationLink(destination: LazyView(PlansView())) {
                Label("subscription_packages".localized(), systemImage: "creditcard")
            }
        }
    }
    
    private var reportsSection: some View {
        Group {
            NavigationLink(destination: LazyView(MonthlyReportView())) {
                Label("monthly_summary".localized(), systemImage: "text.document")
            }
            
            NavigationLink(destination: LazyView(ExportCSVView())) {
                Label("export_csv".localized(), systemImage: "arrow.down.doc")
            }
        }
    }
    
    private var versionSection: some View {
        Section {
            Text("version".localized() + " \(appVersion ?? "")")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Alert Buttons
    private var languageAlertButtons: some View {
        Group {
            Button("restart_now".localized()) {
                exit(0)
            }
            Button("later".localized(), role: .cancel) { }
        }
    }
    
    private var notificationAlertButtons: some View {
        Group {
            Button("open_settings".localized()) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("cancel".localized(), role: .cancel) { }
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                isPushEnabled = isAuthorized && UserDefaults.standard.bool(forKey: "isPushEnabled")
            }
        }
    }
    
    private func handleNotificationToggle() {
        if isPushEnabled {
            // Si el usuario quiere activar las notificaciones
            print("\n🔔 Requesting notification permissions...")
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        isPushEnabled = true
                        UserDefaults.standard.set(true, forKey: "isPushEnabled")
                        print("✅ Notifications permission granted")
                        print("   • Alert notifications: Enabled")
                        print("   • Badge notifications: Enabled")
                        print("   • Sound notifications: Enabled")
                        
                        // Restaurar notificaciones usando el contexto del environment
                        let descriptor = FetchDescriptor<Task>()
                        if let tasks = try? context.fetch(descriptor) {
                            print("🔄 Restoring notifications for existing tasks...")
                            
                            for task in tasks {
                                if !task.isCompleted && task.date > Date() {
                                    scheduleNotification(for: task)
                                    print("   • Restored notifications for task: \(task.title)")
                                }
                            }
                            
                            // Verificar notificaciones programadas
                            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                                print("📋 Total notifications restored: \(requests.count)")
                                print("✨ Notification system ready\n")
                            }
                        }
                    } else {
                        isPushEnabled = false
                        UserDefaults.standard.set(false, forKey: "isPushEnabled")
                        showNotificationSettingsAlert = true
                        print("❌ Notifications permission denied")
                        if let error = error {
                            print("⚠️ Error: \(error.localizedDescription)")
                        }
                        print("💡 User needs to enable notifications in Settings\n")
                    }
                }
            }
        } else {
            // Cuando se desactiva el toggle
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            isPushEnabled = false
            UserDefaults.standard.set(false, forKey: "isPushEnabled")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            print("\n🔕 Disabling all notifications")
            print("✅ All notifications have been removed")
            print("💤 Notification system deactivated\n")
        }
    }
    
    // Función auxiliar para programar notificaciones
    private func scheduleNotification(for task: Task) {
        let notificationDays = [3, 2, 1, 0]
        
        for days in notificationDays {
            let content = UNMutableNotificationContent()
            
            if days == 0 {
                content.title = "task_due_today_title".localized()
                content.body = String(format: "task_due_today_body".localized(), task.title)
            } else {
                content.title = String(format: "task_due_in_days_title".localized(), days)
                content.body = String(format: "task_due_in_days_body".localized(), task.title, days)
            }
            
            content.sound = .default
            
            let notificationDate = Calendar.current.date(byAdding: .day, value: -days, to: task.date) ?? task.date
            
            if notificationDate > Date() {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "task-\(task.id)-\(days)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        // Notificación de retraso
        let delayContent = UNMutableNotificationContent()
        delayContent.title = "task_overdue_title".localized()
        delayContent.body = String(format: "task_overdue_body".localized(), task.title)
        delayContent.sound = .default
        
        let delayDate = Calendar.current.date(byAdding: .hour, value: 1, to: task.date) ?? task.date
        if delayDate > Date() {
            let delayComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: delayDate)
            let delayTrigger = UNCalendarNotificationTrigger(dateMatching: delayComponents, repeats: false)
            
            let delayRequest = UNNotificationRequest(
                identifier: "task-\(task.id)-overdue",
                content: delayContent,
                trigger: delayTrigger
            )
            
            UNUserNotificationCenter.current().add(delayRequest)
        }
    }
    
    // Función para verificar si el dispositivo soporta biometría
    private func biometricType() -> String {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            default:
                return ""
            }
        }
        return ""
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "biometric_usage_description".localized()) { success, error in
                DispatchQueue.main.async {
                    if success {
                        isBiometricEnabled = true
                    } else {
                        // Si falla la autenticación, revertimos el toggle
                        isBiometricEnabled = false
                    }
                }
            }
        } else {
            // Si no se puede usar biometría, revertimos el toggle
            isBiometricEnabled = false
        }
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
    
    private func exportCSV() {
        let fileName = "business_manager_report.csv"
        let header = "Department,Date,Tasks Created,Completed On Time,Total Completed,Performance %,Volume %\n"
        
        let descriptor = FetchDescriptor<Report>()
        let context = try? ModelContainer(for: Report.self).mainContext
        guard let reports = try? context?.fetch(descriptor) else { return }
        
        var csvString = header
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for report in reports {
            let row = [
                report.departmentName,
                dateFormatter.string(from: report.date),
                String(report.totalTasksCreated),
                String(report.tasksCompletedWithoutDelay),
                String(report.numberOfFinishedTasks),
                String(Int(report.performanceMark)),
                String(Int(report.volumeOfWorkMark))
            ].joined(separator: ",")
            
            csvString += row + "\n"
        }
        
        guard let data = csvString.data(using: .utf8) else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)
        
        let activityVC = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func checkICloudStatus() {
        if let _ = FileManager.default.ubiquityIdentityToken {
            iCloudSync = true
        } else {
            iCloudSync = false
        }
    }
}

struct ThemePickerView: View {
    @Binding var selection: Int
    
    private let themes = [
        (title: "system".localized(), icon: "iphone"),
        (title: "light".localized(), icon: "sun.max"),
        (title: "dark".localized(), icon: "moon")
    ]
    
    var body: some View {
        List {
            ForEach(0..<3) { index in
                Button(action: {
                    selection = index
                }) {
                    HStack {
                        Label(themes[index].title, systemImage: themes[index].icon)
                        
                        Spacer()
                        
                        if selection == index {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("theme".localized())
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ThemeCard: View {
    let isSelected: Bool
    let title: String
    let icon: String
    let isDark: Bool
    let showBoth: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                
                if showBoth {
                    HStack(spacing: 12) {
                        PreviewContent(isDark: false)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                        PreviewContent(isDark: true)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                    }
                } else {
                    PreviewContent(isDark: isDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            }
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

struct PreviewContent: View {
    let isDark: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(isDark ? .white : .black)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isDark ? .white : .black)
                        .frame(width: 80, height: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
                        .frame(width: 60, height: 6)
                }
                Spacer()
            }
            
            HStack(spacing: 6) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isDark ? .white.opacity(0.2) : .black.opacity(0.2))
                        .frame(height: 30)
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(isDark ? Color.black : .white)
        }
    }
}

// MARK: - LazyView
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

#Preview {
    SettingsView()
}
