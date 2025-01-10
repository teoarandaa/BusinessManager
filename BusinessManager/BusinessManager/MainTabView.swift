import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedTab = 1
    
    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else {
            TabView(selection: $selectedTab) {
                ReportsView()
                    .tabItem {
                        Label("reports".localized(), systemImage: "text.document")
                    }
                    .tag(0)
                
                ChartsView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("analytics".localized(), systemImage: "chart.bar")
                    }
                    .tag(1)
                
                QualityAnalysisView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("quality".localized(), systemImage: "checkmark.seal")
                    }
                    .tag(2)
                
                TaskView()
                    .tabItem {
                        Label("tasks".localized(), systemImage: "list.bullet.clipboard")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    MainTabView()
}
