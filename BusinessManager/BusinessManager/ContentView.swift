//
//  ContentView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "text.document")
                }
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar")
            }
            TaskView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.clipboard")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
