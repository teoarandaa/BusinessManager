import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isPushEnabled") private var isPushEnabled = false
    @AppStorage("appLanguage") private var appLanguage = "es" // Nuevo AppStorage para el idioma
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showLanguageAlert = false
    
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
