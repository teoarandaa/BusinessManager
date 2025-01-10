import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var showButton = false
    
    private let onboardingPages = [
        OnboardingPage(
            title: "onboarding_welcome".localized(),
            subtitle: "onboarding_welcome_subtitle".localized(),
            description: "onboarding_welcome_description".localized(),
            systemImage: "building.2.fill",
            accentColor: .accentColor
        ),
        OnboardingPage(
        title: "onboarding_business".localized(),
        subtitle: "onboarding_business_subtitle".localized(),
        description: "onboarding_business_description".localized(),
        systemImage: "briefcase.fill",
        accentColor: .accentColor
        ),
        OnboardingPage(
            title: "onboarding_reports".localized(),
            subtitle: "onboarding_reports_subtitle".localized(),
            description: "onboarding_reports_description".localized(),
            systemImage: "chart.bar.horizontal.page",
            accentColor: .accentColor
        ),
        OnboardingPage(
            title: "onboarding_analytics".localized(),
            subtitle: "onboarding_analytics_subtitle".localized(),
            description: "onboarding_analytics_description".localized(),
            systemImage: "chart.line.uptrend.xyaxis",
            accentColor: .accentColor
        ),
        OnboardingPage(
            title: "onboarding_quality".localized(),
            subtitle: "onboarding_quality_subtitle".localized(),
            description: "onboarding_quality_description".localized(),
            systemImage: "checkmark.seal.fill",
            accentColor: .accentColor
        )
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    VStack {
                        Spacer()
                            .frame(height: 60)
                        
                        Image(systemName: onboardingPages[index].systemImage)
                            .font(.system(size: 80))
                            .foregroundStyle(onboardingPages[index].accentColor.gradient)
                            .frame(height: 100)
                        
                        VStack(spacing: 16) {
                            Text(onboardingPages[index].title)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(onboardingPages[index].subtitle)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(onboardingPages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: currentPage == onboardingPages.count - 1 ? .never : .always))
            .onChange(of: currentPage) { oldValue, newValue in
                if newValue == onboardingPages.count - 1 {
                    withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                        showButton = true
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.8)) {
                        showButton = false
                    }
                }
            }
            
            if currentPage == onboardingPages.count - 1 {
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text("get_started".localized())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .frame(height: 50)
                        .background(Color.accentColor.gradient)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 50)
            }
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
    let accentColor: Color
}

#Preview {
    OnboardingView()
}