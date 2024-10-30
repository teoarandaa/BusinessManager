//
//  PrivacyView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct PrivacyView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // MARK: - Display for privacy items
    var body: some View {
        List {
            Section("General Policies") {
                NavigationLink(destination: TermsOfUseView()) {
                    Text("Terms of Use")
                }
            }
        }
        .navigationTitle("Privacy")
    }
}

#Preview {
    PrivacyView()
}
