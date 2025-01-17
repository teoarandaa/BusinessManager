import SwiftUI
import SwiftData
import LocalAuthentication

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    @AppStorage("appLanguage") private var appLanguage = "es" // Nuevo AppStorage para el idioma
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled = false // Nuevo AppStorage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.modelContext) private var context
    @State private var showLanguageAlert = false
    @State private var showNotificationSettingsAlert = false
    
    // Definir los idiomas disponibles
    private let availableLanguages = [
        ("es", "Español"),
        ("en", "English"),
        ("pt", "Português"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("it", "Italiano")
    ]
    
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
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Language
                Section("language".localized()) {
                    Label {
                        Picker("select_language".localized(), selection: $appLanguage) {
                            ForEach(availableLanguages, id: \.0) { language in
                                Text(language.1).tag(language.0)
                            }
                        }
                    } icon: {
                        Image(systemName: "globe")
                    }
                    .onChange(of: appLanguage) { oldValue, newValue in
                        UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        showLanguageAlert = true
                    }
                }
                
                // MARK: - Notifications
                Section("notifications".localized()) {
                    Toggle(isOn: $isPushEnabled) {
                        Label {
                            Text("push_notifications".localized())
                        } icon: {
                            Image(systemName: isPushEnabled ? "bell" : "bell.slash")
                                .symbolEffect(.bounce, value: isPushEnabled)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                    .onChange(of: isPushEnabled) { oldValue, newValue in
                        handleNotificationToggle()
                    }
                }
                // MARK: - Appearance
                Section("appearance".localized()) {
                    HStack {
                        Label {
                            NavigationLink {
                                ThemePickerView(selection: $colorScheme)
                            } label: {
                                HStack {
                                    Text("theme".localized())
                                    Spacer()
                                    Text(colorScheme == 0 ? "system".localized() : 
                                         colorScheme == 1 ? "light".localized() : "dark".localized())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "paintbrush")
                        }
                    }
                }
                // MARK: - Plans
                Section("pricing".localized()) {
                    NavigationLink(destination: PlansView()) {
                        Label("subscription_packages".localized(), systemImage: "creditcard")
                    }
                }
                // MARK: - Resources
                Section("resources".localized()) {
                    NavigationLink(destination: FaqView()) {
                        Label("faq".localized(), systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: PrivacyView()) {
                        Label("privacy".localized(), systemImage: "lock")
                    }
                    Button(action: {
                        sendEmail(to: "help.businessmanager@gmail.com")
                    }) {
                        Label("support".localized(), systemImage: "envelope")
                    }
                }
                // MARK: - Reports
                Section("reports".localized()) {
                    NavigationLink(destination: MonthlyReportView()) {
                        Label("monthly_summary".localized(), systemImage: "text.document")
                    }
                    NavigationLink(destination: ExportCSVView()) {
                        Label("export_csv".localized(), systemImage: "arrow.down.doc")
                    }
                }
                // Añadir nueva sección de seguridad después de notificaciones
                if !biometricType().isEmpty {
                    Section("security".localized()) {
                        Toggle(isOn: Binding(
                            get: { isBiometricEnabled },
                            set: { newValue in
                                if newValue {
                                    authenticateWithBiometrics()
                                } else {
                                    isBiometricEnabled = false
                                }
                            }
                        )) {
                            Label {
                                Text("biometric_authentication".localized())
                            } icon: {
                                Image(systemName: biometricType() == "Face ID" ? "faceid" : "touchid")
                                    .symbolEffect(.bounce, value: isBiometricEnabled)
                            }
                        }
                    }
                }
                Section {
                    Text("version".localized() + " \(appVersion!)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color(.systemGroupedBackground))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings".localized())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
            .alert("language_change_title".localized(), isPresented: $showLanguageAlert) {
                Button("restart_now".localized()) {
                    exit(0) // Esto cerrará la app
                }
                Button("later".localized(), role: .cancel) { }
            } message: {
                Text("language_change_message".localized())
            }
            .onAppear {
                checkNotificationStatus()
            }
            .alert("notifications_settings_title".localized(), isPresented: $showNotificationSettingsAlert) {
                Button("open_settings".localized()) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("cancel".localized(), role: .cancel) { }
            } message: {
                Text("notifications_settings_message".localized())
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
}

struct ThemePickerView: View {
    @Binding var selection: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    @State private var temporarySelection: Int
    
    init(selection: Binding<Int>) {
        self._selection = selection
        self._temporarySelection = State(initialValue: selection.wrappedValue)
    }
    
    private func hapticFeedback() {
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<3) { index in
                    ThemeCard(
                        isSelected: temporarySelection == index,
                        title: themeTitle(for: index),
                        icon: "",
                        preview: {
                            themePreview(for: index)
                        },
                        action: {
                            hapticFeedback()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                temporarySelection = index
                                selection = index
                            }
                        },
                        namespace: animation
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding()
        }
        .navigationTitle("theme".localized())
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("done".localized()) {
                    dismiss()
                }
            }
        }
    }
    
    private func themeTitle(for index: Int) -> String {
        switch index {
        case 0: return "system".localized()
        case 1: return "light".localized()
        default: return "dark".localized()
        }
    }
    
    private func themeIcon(for index: Int) -> String {
        switch index {
        case 0: return "iphone"
        case 1: return "sun.max"
        default: return "moon"
        }
    }
    
    private func themePreview(for index: Int) -> AnyView {
        AnyView(
            Group {
                switch index {
                case 0:
                    HStack(spacing: 12) {
                        previewCard(isDark: false)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                        previewCard(isDark: true)
                    }
                    .frame(height: 100)
                case 1:
                    previewCard(isDark: false)
                        .frame(height: 100)
                default:
                    previewCard(isDark: true)
                        .frame(height: 100)
                }
            }
        )
    }
}

struct ThemeCard: View {
    let isSelected: Bool
    let title: String
    let icon: String
    let preview: () -> AnyView
    let action: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                
                AnyView(preview())
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? .white.opacity(0.5) : .clear, lineWidth: 2)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isSelected ? 1.02 : 1)
            .shadow(color: isSelected ? .accentColor.opacity(0.3) : .clear, radius: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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

@ViewBuilder
private func previewCard(isDark: Bool) -> some View {
    PreviewContent(isDark: isDark)
        .scaleEffect(0.8)
}

#Preview {
    SettingsView()
}
