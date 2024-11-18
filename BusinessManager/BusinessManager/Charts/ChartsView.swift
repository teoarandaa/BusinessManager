//
//  ChartsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI
import SwiftData

struct ChartsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var chart: String = "Productivity" // Valor inicial
    let chartOptions = ["Productivity", "Workload", "Performance", "Trends"]
    @Environment(\.modelContext) var context
    
    var body: some View {
        VStack {
            Picker("Charts", selection: $chart) {
                ForEach(chartOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Group {
                switch chart {
                case "Productivity":
                    ProductivityChartView()
                case "Workload":
                    WorkloadChartView()
                case "Performance":
                    PerformanceChartView()
                case "Trends":
                    TrendChartView()
                default:
                    Text("Select a chart")
                }
            }
        }
    }
}

#Preview {
    ChartsView()
}
