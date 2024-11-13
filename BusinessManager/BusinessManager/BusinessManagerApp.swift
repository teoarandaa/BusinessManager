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
    
    /*
    let container: ModelContainer = {
        let schema = Schema([Reports.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    */
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
//        .modelContainer(container)        --> Coge el container creado arriba. Es mas personalizable
        .modelContainer(for: [Report.self]) // --> Usa los esenciales para pasar la informacion, a diferencia del de arriba
    }
}
