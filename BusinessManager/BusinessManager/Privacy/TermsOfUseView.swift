//
//  TermsOfUseView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct TermsOfUseView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text("1. Acceptance of Terms\n")
                        
                    Text("By downloading or using the CleanCode mobile application, you agree to these Terms of Use. If you do not agree with these terms, please do not use the app\n")
                        
                    Text("2. Description of Service\n")
                        
                    Text("The App provides tools to optimize and clean code. Additional services may be available for purchase through the App.\n")
                        
                    Text("3. In-App Purchases\n")
                        
                    Text("      a. Payment and Billing\n")
                        
                    Text("      All payments for In-App Purchases will be handled by the relevant application platform and will be subject to their payment terms and conditions. We do not have access to or store your payment details.\n")
                        
                    Text("      b. Refunds\n")
                        
                    Text("      Refund requests must be directed to the relevant application platform, as they manage the payment process. We do not offer refunds directly. All refund requests are subject to the application platform's policies and guidelines.\n")
                        
                    Text("      c. Price Changes\n")
                        
                    Text("      We reserve the right to change the prices of Products at any time. Price changes will not affect any prior purchases that have already been completed.\n")
                        
                    Text("4. Intellectual Property\n")
                        
                    Text("All content within the App, including but not limited to text, graphics, logos, and software, is owned by or licensed to CleanCode and is protected by applicable intellectual property laws. Unauthorized use of any content from the App is prohibited.\n")
                        
                    Text("5. Limitation of Liability\n")
                        
                    Text("The App and all content and services provided are available \"as is\" without any warranties, express or implied. To the fullest extent permissible under applicable law, we disclaim all warranties, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, and non-infringement.\n")
                        
                    Text("6. Changes to Terms of Use\n")
                        
                    Text("We reserve the right to update or modify these Terms of Use at any time. The most current version will always be available within the App. Continued use of the App after any such modifications constitutes acceptance of the updated Terms of Use.\n")
                        
                    Text("7. Termination\n")
                        
                    Text("We reserve the right to terminate or suspend access to the App for users who violate these Terms of Use or for any other reason, at our discretion.\n")
                        
                    Text("8. Governing Law\n")
                        
                    Text("These Terms of Use are governed by the laws of Spain. Any disputes arising from or related to the use of the App will be resolved in accordance with the laws of Spain.\n")
                        
                    Text("9. Contact Information\n")
                    
                    Text("For questions or concerns about these Terms of Use, please contact us at help.cleancode@gmail.com.")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Terms of Use")
        }
    }
}

#Preview {
    TermsOfUseView()
}
