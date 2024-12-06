import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "text.document")
                }
                .tag(0)
            
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar")
                }
                .tag(1)
            
            TaskView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.clipboard")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
