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
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header con imagen grande
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.accentColor)
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: onboardingPages[index].systemImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .padding(60)
                                )
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            
                            // Título y subtítulo principales
                            VStack(spacing: 8) {
                                Text(onboardingPages[index].title)
                                    .font(.title)
                                    .bold()
                                Text(onboardingPages[index].subtitle)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            
                            // Descripción
                            Text(onboardingPages[index].description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            Spacer()
                        }
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(duration: 0.3), value: currentPage)
            .safeAreaInset(edge: .bottom) {
                // Barra de progreso/Botón
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fondo
                        RoundedRectangle(cornerRadius: currentPage == onboardingPages.count - 1 ? 10 : 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 200, height: currentPage == onboardingPages.count - 1 ? 50 : 6)
                            .frame(height: 50, alignment: .center)
                        
                        // Barra de progreso/Botón
                        RoundedRectangle(cornerRadius: currentPage == onboardingPages.count - 1 ? 10 : 8)
                            .fill(Color.accentColor)
                            .frame(
                                width: currentPage == onboardingPages.count - 1 ? 200 : 200 * progress,
                                height: currentPage == onboardingPages.count - 1 ? 50 : 6
                            )
                            .frame(height: 50, alignment: .center)
                            .overlay {
                                if currentPage == onboardingPages.count - 1 {
                                    Text("get_started".localized())
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.spring(duration: 0.3), value: currentPage)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentPage == onboardingPages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showOnboarding = false
                            }
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom, 20)
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