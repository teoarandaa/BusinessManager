import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "text.document")
                }
                .tag(0)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(1)
            
            ChartsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Charts", systemImage: "chart.bar")
                }
                .tag(2)
            
            TaskView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.clipboard")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
