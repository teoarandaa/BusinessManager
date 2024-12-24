import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    // Privacy Icon
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor)
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "lock.iphone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .padding(50)
                        )
                        .padding(.bottom, 20)
                    
                    Text("last_updated".localized())
                        .font(.footnote)
                    
                    Text("privacy_policy_main".localized())
                        .font(.title2)
                        .bold()
                    
                    Text("privacy_policy_details".localized())
                        .font(.callout)
                        
                    Text("contact_us".localized())
                        .font(.title2)
                        .bold()
                        
                    (Text("privacy_contact_prefix".localized()) +
                    Text("privacy_email".localized())
                        .foregroundColor(.accentColor)
                        .underline())
                        .font(.callout)
                        .onTapGesture {
                            if let url = URL(string: "mailto:help.businessmanager@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("privacy_policy".localized())
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 
