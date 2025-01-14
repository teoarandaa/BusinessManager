import SwiftUI

struct LanguageSelectionView: View {
    @Binding var showLanguageSelection: Bool
    @Binding var showOnboarding: Bool
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var titleOffset: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var backgroundOpacity: Double = 1
    @State private var navTitleOpacity: Double = 0
    @State private var isNavigating: Bool = false
    @State private var selectedLanguage: String? = nil
    
    private let languages = [
        ("English", "🇺🇸", "en"),
        ("Español", "🇪🇸", "es"),
        ("Português", "🇵🇹", "pt"),
        ("Français", "🇫🇷", "fr"),
        ("Deutsch", "🇩🇪", "de"),
        ("Italiano", "🇮🇹", "it")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .systemBackground)
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                NavigationStack {
                    VStack {
                        Spacer()
                            .frame(height: geometry.size.height * 0.15)
                        
                        // Contenido principal
                        VStack(spacing: 60) {
                            Text("Select your language")
                                .font(.title2)
                                .foregroundColor(.white)
                                .bold()
                            
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(languages, id: \.2) { language in
                                        Button {
                                            handleLanguageSelection(language)
                                        } label: {
                                            HStack {
                                                Text(language.1)
                                                    .font(.title2)
                                                Text(language.0)
                                                    .font(.title3)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 16)
                                            .padding(.horizontal)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.1))
                                            )
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .opacity(contentOpacity)
                        
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        ZStack {
                            // Título animado
                            if titleOpacity > 0 && !isNavigating {
                                Text("Business Manager")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.accentColor)
                                    .offset(y: titleOffset)
                                    .opacity(titleOpacity)
                            }
                            
                            // Título fijo
                            Text("Business Manager")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.accentColor)
                                .offset(y: -geometry.size.height * 0.4)
                                .opacity(navTitleOpacity)
                        }
                    }
                }
            }
            .onAppear {
                titleOffset = -geometry.size.height * 0.01
                titleOpacity = 1
                contentOpacity = 0
                backgroundOpacity = 1
                navTitleOpacity = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 1.2)) {
                        titleOffset = -geometry.size.height * 0.4
                        backgroundOpacity = 0
                    }
                    
                    withAnimation(.easeIn(duration: 0.5).delay(1.2)) {
                        titleOpacity = 0
                        navTitleOpacity = 1
                    }
                    
                    withAnimation(.easeIn(duration: 0.7).delay(1.2)) {
                        contentOpacity = 1
                    }
                }
            }
        }
    }
    
    private func handleLanguageSelection(_ language: (String, String, String)) {
        isNavigating = true
        
        // Desvanecer todo junto
        withAnimation(.easeOut(duration: 0.3)) {
            contentOpacity = 0
            titleOpacity = 0
            backgroundOpacity = 0
            navTitleOpacity = 0
        }
        
        // Cambiar al onboarding después de un breve desvanecimiento
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Cambiar el idioma
            UserDefaults.standard.set([language.2], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            appLanguage = language.2
            
            // Forzar el cambio de idioma
            if let languageURL = Bundle.main.url(forResource: language.2, withExtension: "lproj"),
               let bundle = Bundle(url: languageURL) {
                Bundle.setLanguage(bundle)
                NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            }
            
            // Cambiar directamente al onboarding
            showLanguageSelection = false
            showOnboarding = true
        }
    }
}

#Preview {
    LanguageSelectionView(showLanguageSelection: .constant(true), showOnboarding: .constant(false))
} 