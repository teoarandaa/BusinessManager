//
//  SettingsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // MARK: - Sections for every setting
    var body: some View {
        List {
            // MARK: - Notifications
            Section("Notifications") {
                Toggle (isOn: $isDarkMode){
                    Text("Push notifications")
                }
            }
            // MARK: - Appearance
            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Text("Dark mode")
                }
            }
            // MARK: - Others
            Section("Others") {
                NavigationLink(destination: FaqView()) {
                    Text("FAQ (Frequently Asked Questions")
                }
                NavigationLink(destination: PrivacyView()) {
                    Text("Privacy")
                }
                Button(action: {
                    sendEmail(to: "help.cleancode@gmail.com")
                }) {
                    Text("CleanCode Support")
                }
            }
        }
        .navigationTitle("Settings")
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    func sendEmail(to address: String) {
        if let url = URL(string: "mailto:\(address)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}
