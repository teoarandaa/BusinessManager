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
            
            ChartsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(1)
            
            QualityAnalysisView()
                .tabItem {
                    Label("Quality", systemImage: "checkmark.seal")
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
