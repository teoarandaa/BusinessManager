//
//  ReportsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Text("Reports")
    }
}

#Preview {
    ReportsView()
}
