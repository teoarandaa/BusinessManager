import SwiftUI
import SwiftData
import UserNotifications
import CloudKit
import Network

@main
struct BusinessManagerApp: App {
    let container: ModelContainer
    @AppStorage("colorScheme") private var colorScheme = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("appLanguage") private var appLanguage = "es"
    @AppStorage("iCloudSync") private var iCloudSync = false
    @AppStorage("lastSyncDate") private var lastSyncDate = Date()
    @AppStorage("isNetworkAvailable") private var isNetworkAvailable = false
    @State private var isAuthenticated = false
    private let networkMonitor = NWPathMonitor()
    
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
            
            // Después de inicializar el container, podemos configurar el resto
            UserDefaults.standard.set([appLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            // Ahora que todas las propiedades están inicializadas, configuramos la red
            setupNetworkMonitoring()
            checkICloudStatus()
            setupICloudObserver()
            requestNotificationPermission()
            
        } catch {
            print("CloudKit Error: \(error)")
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isNetworkAvailable = path.status == .satisfied
                if isNetworkAvailable {
                    checkICloudStatus() // Verificar iCloud cuando la red esté disponible
                } else {
                    iCloudSync = false // Desactivar iCloud cuando no hay red
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
    private func checkICloudStatus() {
        guard isNetworkAvailable else {
            iCloudSync = false
            return
        }
        
        CKContainer.default().accountStatus { [self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    iCloudSync = true
                    lastSyncDate = Date()
                case .noAccount, .restricted, .couldNotDetermine, .temporarilyUnavailable:
                    iCloudSync = false
                @unknown default:
                    iCloudSync = false
                }
            }
        }
    }
    
    private func setupICloudObserver() {
        // Observar cambios en el estado de inicio de sesión de iCloud
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { _ in
            checkICloudStatus()
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
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NSUbiquityIdentityDidChange)) { _ in
                checkICloudStatus()
            }
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
