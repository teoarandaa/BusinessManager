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
                
                Text("Reports offer insights into performance, productivity, and progress. Securely stored and organized by type and date, they help you track and share results, ensuring quick access for smarter decisions.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Image("reports1") // Replace with your image name
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
                
                Text("To create accurate reports, we need the current date, department name, performance, volume of work, and tasks completed. This data is then displayed in charts, providing clear insights into productivity, workload, and performance, helping you make informed, data-driven decisions.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Image("reports2") // Replace with your image name
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
