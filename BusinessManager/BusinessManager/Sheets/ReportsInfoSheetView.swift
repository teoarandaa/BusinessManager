//
//  ReportsInfoSheetView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 20/11/24.
//

import SwiftUI

struct ReportsInfoSheetView: View {
    var body: some View {
        TabView {
            // First Page
            VStack {
                Text("Reports Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("This section provides an overview of the reports generated.")
                    .padding()
                
                Image("reports_overview") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            .tabItem {
                Text("Overview")
            }
            
            // Second Page
            VStack {
                Text("How to Create Reports")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Follow these steps to create a report...")
                    .padding()
                
                Image("create_report") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            .tabItem {
                Text("Creating Reports")
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

#Preview {
    ReportsInfoSheetView()
}
