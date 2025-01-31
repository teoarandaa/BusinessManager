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
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.businessmanager.BusinessManager")
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
            
            // Configurar observador de cambios de CloudKit
            setupCloudKitSubscription()
            
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
            print("iCloud sync disabled - network unavailable")
            return
        }
        
        CKContainer.default().accountStatus { [self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("iCloud status check error: \(error.localizedDescription)")
                }
                
                switch status {
                case .available:
                    iCloudSync = true
                    lastSyncDate = Date()
                    print("iCloud status: Available")
                    // Verificar el contenedor específico
                    CKContainer(identifier: "iCloud.com.businessmanager.BusinessManager").privateCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: "TestRecord")) { record, error in
                        if let error = error {
                            print("Container verification error: \(error.localizedDescription)")
                        }
                    }
                case .noAccount:
                    print("iCloud status: No Account")
                    iCloudSync = false
                case .restricted:
                    print("iCloud status: Restricted")
                    iCloudSync = false
                case .couldNotDetermine:
                    print("iCloud status: Could Not Determine")
                    iCloudSync = false
                case .temporarilyUnavailable:
                    print("iCloud status: Temporarily Unavailable")
                    iCloudSync = false
                @unknown default:
                    print("iCloud status: Unknown")
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
    
    private func setupCloudKitSubscription() {
        let subscriptionID = "BusinessManagerDataChanges"
        let subscription = CKQuerySubscription(
            recordType: "CD_Report",
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().privateCloudDatabase.save(subscription) { _, error in
            if let error = error {
                print("Error setting up CloudKit subscription: \(error)")
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
