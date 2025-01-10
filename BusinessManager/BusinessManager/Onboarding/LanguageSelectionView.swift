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
                // Fondo del sistema
                Color(uiColor: .systemBackground)
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                NavigationStack {
                    VStack(spacing: 24) {
                        // Resto del contenido
                        VStack(spacing: 24) {
                            Text("Select your language")
                                .font(.title2)
                                .bold()
                            
                            ScrollView {
                                VStack(spacing: 12) {
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
                                            .padding()
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
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Business Manager")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.accentColor)
                                .opacity(navTitleOpacity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        if titleOpacity > 0 && !isNavigating {
                            Text("Business Manager")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.accentColor)
                                .offset(y: titleOffset)
                                .opacity(titleOpacity)
                        }
                    }
                }
            }
            .onAppear {
                // Configurar estado inicial
                titleOffset = geometry.size.height / 2 - 407
                titleOpacity = 1
                contentOpacity = 0
                backgroundOpacity = 1
                navTitleOpacity = 0
                
                // Esperar 1 segundo antes de comenzar la animación
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Animar el título hacia arriba
                    withAnimation(.easeOut(duration: 1.2)) {
                        titleOffset = -geometry.size.height / 2 + 0
                        backgroundOpacity = 0
                    }
                    
                    // Desvanecer el título animado y mostrar el título de navegación
                    withAnimation(.easeIn(duration: 0.5).delay(1.2)) {
                        titleOpacity = 0
                        navTitleOpacity = 1
                    }
                    
                    // Mostrar el contenido ligeramente después
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