import SwiftUI

struct PrivacyView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("privacy_policy".localized())
                }
                
                NavigationLink(destination: TermsOfUseView()) {
                    Text("terms_of_use".localized())
                }
                
                NavigationLink(destination: ICloudInfoView()) {
                    Text("icloud_info".localized())
                }
            }
        }
        .navigationTitle("privacy".localized())
    }
}

#Preview {
    PrivacyView()
}
