//
//  ChartsInfoSheetView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 28/11/24.
//

import SwiftUI

struct ChartsInfoSheetView: View {
    var body: some View {
        TabView {
            // First Page
            VStack {
                Text("Charts Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Charts visualize key metrics for each department. The Productivity Chart tracks performance trends over time. The Workload Chart compares performance to workload with a scatter plot, highlighting efficiency. The Performance Chart shows average workload versus completed tasks in a bar chart, measuring task efficiency.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Image("charts1") // Replace with your image name
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
                Text("How to Create Charts")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("They are generated using data from reports. Information such as performance, workload, and tasks completed is processed to create visual representations that highlight key insights. These charts help analyze trends, efficiency, and productivity for each department, turning raw data into actionable information.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Image("charts2") // Replace with your image name
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
    ChartsInfoSheetView()
}
