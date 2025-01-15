import SwiftUI

struct LanguageSelectionView: View {
    @Binding var showLanguageSelection: Bool
    @Binding var showOnboarding: Bool
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var contentOpacity: Double = 0
    @State private var backgroundOpacity: Double = 1
    @State private var navTitleOpacity: Double = 0
    @State private var isNavigating: Bool = false
    @State private var selectedLanguage: String? = nil
    @State private var languageOffsets: [String: CGFloat] = [:]
    @State private var languageOpacities: [String: Double] = [:]
    @State private var selectLanguageTitleOpacity: Double = 0
    @State private var fullScreenOverlay: Bool = false
    @State private var currentTitleIndex = 0
    
    private let languages = [
        ("English", "🇺🇸", "en"),
        ("Español", "🇪🇸", "es"),
        ("Português", "🇵🇹", "pt"),
        ("Français", "🇫🇷", "fr"),
        ("Deutsch", "🇩🇪", "de"),
        ("Italiano", "🇮🇹", "it")
    ]
    
    private let titleTexts = [
        "Select your language",
        "Selecciona tu idioma",
        "Sélectionnez votre langue",
        "Seleziona la tua lingua",
        "Wählen Sie Ihre Sprache",
        "Selecione seu idioma"
    ]
    
    // Timer para cambiar el texto
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.primary
                    .opacity(fullScreenOverlay ? 1 : 0)
                    .ignoresSafeArea()
                
                Color(uiColor: .systemBackground)
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                NavigationStack {
                    GeometryReader { geometry in
                        VStack(spacing: 20) {
                            Image("initialAppIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .opacity(selectLanguageTitleOpacity)
                            
                            Text(titleTexts[currentTitleIndex])
                                .font(.title2)
                                .foregroundColor(.white)
                                .bold()
                                .opacity(selectLanguageTitleOpacity)
                                .transition(.numericText())
                                .animation(.easeInOut(duration: 0.5), value: currentTitleIndex)
                                .id(currentTitleIndex)
                            
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
                                    .offset(y: languageOffsets[language.2] ?? 50)
                                    .opacity(languageOpacities[language.2] ?? 0)
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 40)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .onReceive(timer) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentTitleIndex = (currentTitleIndex + 1) % titleTexts.count
                            }
                        }
                    }
                }
            }
            .onAppear {
                contentOpacity = 1
                backgroundOpacity = 1
                selectLanguageTitleOpacity = 0
                
                // Inicializar offsets y opacidades
                for language in languages {
                    languageOffsets[language.2] = 100
                    languageOpacities[language.2] = 0
                }
                
                withAnimation(.easeIn(duration: 0.5)) {
                    selectLanguageTitleOpacity = 1
                }
                
                // Animar cada idioma secuencialmente desde abajo
                for (index, language) in languages.enumerated() {
                    withAnimation(
                        .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)
                        .delay(0.3 + Double(index) * 0.15)
                    ) {
                        languageOffsets[language.2] = 0
                        languageOpacities[language.2] = 1
                    }
                }
            }
        }
    }
    
    private func handleLanguageSelection(_ language: (String, String, String)) {
        isNavigating = true
        
        // Primero animamos la salida de los elementos
        withAnimation(.easeInOut(duration: 0.5)) {
            selectLanguageTitleOpacity = 0
            navTitleOpacity = 0
            backgroundOpacity = 0
            fullScreenOverlay = true
            
            // Animar idiomas hacia abajo
            for (index, lang) in languages.enumerated() {
                withAnimation(
                    .easeInOut(duration: 0.3)
                    .delay(Double(index) * 0.05)
                ) {
                    languageOffsets[lang.2] = 100
                    languageOpacities[lang.2] = 0
                }
            }
        }
        
        // Cambiar el idioma y transicionar directamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserDefaults.standard.set([language.2], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            appLanguage = language.2
            
            if let languageURL = Bundle.main.url(forResource: language.2, withExtension: "lproj"),
               let bundle = Bundle(url: languageURL) {
                Bundle.setLanguage(bundle)
                NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            }
            
            // Transición inmediata al onboarding
            withAnimation(.easeOut(duration: 0.3)) {
                showLanguageSelection = false
                showOnboarding = true
            }
        }
    }
}

extension AnyTransition {
    static func numericText() -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}

#Preview {
    LanguageSelectionView(showLanguageSelection: .constant(true), showOnboarding: .constant(false))
} 