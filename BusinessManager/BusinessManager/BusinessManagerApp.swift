import SwiftUI
import SwiftData

@main
struct BusinessManagerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Report.self, Task.self])
    }
}
