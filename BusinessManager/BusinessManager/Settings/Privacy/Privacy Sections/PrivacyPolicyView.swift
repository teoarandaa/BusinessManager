import SwiftUI

struct PrivacyPolicyView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
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
                    
                    Text("Last updated: December 06, 2024\n")
                        .font(.footnote)
                    
                    Text("Business Manager for SwiftUI does not collect any data about you.\n")
                        .font(.title2)
                        .bold()
                    
                    Text("All data will be securely stored on your device. If at any time we change our Privacy Policy, we will notify you with a notification.\n")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        
                    Text("Contact Us\n")
                        .font(.title2)
                        .bold()
                        
                    Text("If you have questions about this Privacy Policy, please contact us at help.businessmanager@gmail.com.")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Privacy Policy")
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 
