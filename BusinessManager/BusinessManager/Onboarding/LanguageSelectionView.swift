import SwiftUI

struct LanguageSelectionView: View {
    @Binding var showLanguageSelection: Bool
    @Binding var showOnboarding: Bool
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    private let languages = [
        ("English", "🇺🇸", "en"),
        ("Español", "🇪🇸", "es"),
        ("Português", "🇵🇹", "pt"),
        ("Français", "🇫🇷", "fr"),
        ("Deutsch", "🇩🇪", "de"),
        ("Italiano", "🇮🇹", "it")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .padding(.top, 40)
                
                Text("Select your language")
                    .font(.title2)
                    .bold()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(languages, id: \.2) { language in
                            Button {
                                // Cambiar el idioma y reiniciar
                                UserDefaults.standard.set([language.2], forKey: "AppleLanguages")
                                UserDefaults.standard.synchronize()
                                
                                // Actualizar el AppStorage para el picker en SettingsView
                                appLanguage = language.2
                                
                                // Forzar el cambio de idioma
                                if let languageURL = Bundle.main.url(forResource: language.2, withExtension: "lproj"),
                                   let bundle = Bundle(url: languageURL) {
                                    Bundle.setLanguage(bundle)
                                    
                                    // Forzar actualización de la interfaz
                                    NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
                                }
                                
                                withAnimation {
                                    showLanguageSelection = false
                                    showOnboarding = true
                                }
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
        }
    }
}

#Preview {
    LanguageSelectionView(showLanguageSelection: .constant(true), showOnboarding: .constant(false))
} 