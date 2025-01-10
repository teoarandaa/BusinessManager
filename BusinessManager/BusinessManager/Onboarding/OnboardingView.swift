import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showButton = false
    @Binding var showOnboarding: Bool
    
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
    
    var progress: CGFloat {
        CGFloat(currentPage) / CGFloat(onboardingPages.count - 1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            // Barra de progreso/Botón unificado
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo
                    RoundedRectangle(cornerRadius: currentPage == onboardingPages.count - 1 ? 10 : 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: currentPage == onboardingPages.count - 1 ? 50 : 6)
                    
                    // Barra de progreso/Botón
                    RoundedRectangle(cornerRadius: currentPage == onboardingPages.count - 1 ? 10 : 8)
                        .fill(Color.accentColor.gradient)
                        .frame(width: currentPage == onboardingPages.count - 1 ? geometry.size.width : geometry.size.width * progress,
                               height: currentPage == onboardingPages.count - 1 ? 50 : 6)
                        .overlay {
                            if currentPage == onboardingPages.count - 1 {
                                Text("get_started".localized())
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(showButton ? 1 : 0)
                                    .animation(.easeIn.delay(0.2), value: showButton)
                            }
                        }
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if currentPage == onboardingPages.count - 1 {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showOnboarding = false
                        }
                    }
                }
            }
            .frame(width: 200, height: 50)
            .padding(.bottom, 20)
            .animation(.spring(duration: 0.5), value: currentPage)
            .onChange(of: currentPage) { oldValue, newValue in
                if newValue == onboardingPages.count - 1 {
                    withAnimation(.easeIn.delay(0.3)) {
                        showButton = true
                    }
                } else {
                    showButton = false
                }
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
    OnboardingView(showOnboarding: .constant(true))
}