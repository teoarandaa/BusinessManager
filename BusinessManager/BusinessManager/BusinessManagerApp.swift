//
//  BusinessManagerApp.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI
import SwiftData

@main
struct BusinessManagerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Report.self, Task.self])
    }
}
