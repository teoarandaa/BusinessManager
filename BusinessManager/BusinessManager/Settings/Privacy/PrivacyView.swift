import SwiftUI

struct PrivacyView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        List {
            Section("general_policies".localized()) {
                NavigationLink(destination: TermsOfUseView()) {
                    Text("terms_of_use".localized())
                }
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("privacy_policy".localized())
                }
            }
        }
        .navigationTitle("privacy".localized())
    }
}

#Preview {
    PrivacyView()
}
