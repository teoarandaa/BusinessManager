import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    @AppStorage("appLanguage") private var appLanguage = "es" // Nuevo AppStorage para el idioma
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
                isPushEnabled = settings.authorizationStatus == .authorized
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
            // Si el usuario quiere desactivar las notificaciones
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print("\n🔕 Disabling all notifications")
                print("📋 Pending notifications being removed: \(requests.count)")
                
                if requests.isEmpty {
                    print("ℹ️ No pending notifications to remove")
                } else {
                    for request in requests {
                        print("   • Removing notification: \(request.identifier)")
                    }
                }
                
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("✅ All notifications have been disabled successfully")
                print("💤 Notification system deactivated\n")
            }
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
    
    var body: some View {
        List {
            Button {
                selection = 0
                dismiss()
            } label: {
                Label {
                    Text("system".localized())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                } icon: {
                    Image(systemName: "iphone")
                        .foregroundStyle(.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                selection = 1
                dismiss()
            } label: {
                Label {
                    Text("light".localized())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                } icon: {
                    Image(systemName: "sun.max")
                        .foregroundStyle(.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                selection = 2
                dismiss()
            } label: {
                Label {
                    Text("dark".localized())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                } icon: {
                    Image(systemName: "moon")
                        .foregroundStyle(.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("theme".localized())
    }
}

#Preview {
    SettingsView()
}
