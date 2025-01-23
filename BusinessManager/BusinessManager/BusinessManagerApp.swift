import SwiftUI
import SwiftData
import UserNotifications
import CloudKit

@main
struct BusinessManagerApp: App {
    let container: ModelContainer
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("appLanguage") private var appLanguage = "es"
    @State private var isAuthenticated = false
    
    init() {
        do {
            let schema = Schema([
                Report.self,
                Task.self,
                QualityMetric.self,
                QualityInsight.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Configurar el idioma al iniciar la app
            UserDefaults.standard.set([appLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            requestNotificationPermission()
            
        } catch {
            print("CloudKit Error: \(error)")
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    MainTabView()
                        .modelContainer(container)
                        .preferredColorScheme(colorSchemeValue)
                } else {
                    BiometricAuthView(isAuthenticated: $isAuthenticated)
                }
            }
            .animation(.easeInOut, value: isAuthenticated)
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
}
