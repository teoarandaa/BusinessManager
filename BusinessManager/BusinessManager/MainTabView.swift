import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 2
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .onChange(of: showOnboarding) { _, newValue in
                        if !newValue {
                            hasCompletedOnboarding = true
                        }
                    }
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
}

#Preview {
    MainTabView()
}
