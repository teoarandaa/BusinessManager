//
//  ChartsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI

struct ChartsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Text("Charts")
    }
}

#Preview {
    ChartsView()
}
