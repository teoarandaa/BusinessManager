import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled = false
    @State private var selectedTab = 2
    @State private var showOnboarding = true
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if !isAuthenticated && isBiometricEnabled {
                BiometricAuthView(isAuthenticated: $isAuthenticated)
            } else {
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
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
        .onAppear {
            // Si no está habilitada la autenticación biométrica, marcamos como autenticado
            if !isBiometricEnabled {
                isAuthenticated = true
            }
        }
    }
}

#Preview {
    MainTabView()
}
