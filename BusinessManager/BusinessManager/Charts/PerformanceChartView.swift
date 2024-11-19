//
//  PerformanceChartView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 17/11/24.
//

import SwiftUI
import SwiftData
import Charts

struct PerformanceChartView: View {
    @Query var reports: [Report] // Retrieves the data stored in SwiftData
    
    var chartData: [ChartData] {
        reports.map { ChartData(from: $0) }
    }

    var body: some View {
        Chart(chartData) { data in
            PointMark(
                x: .value("Department", data.departmentName),
                y: .value("Tasks Completed", data.numberOfFinishedTasks)
            )
            .foregroundStyle(by: .value("Department", data.departmentName))
            .symbolSize(data.size) // Controls the size of the bubble based on tasks completed
            .symbol(by: .value("Department", data.departmentName))
        }
        .chartXAxis {
            AxisMarks()
        }
        .chartYAxis {
            AxisMarks()
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding()
        .navigationTitle("Tasks by Department")
    }
}

#Preview {
    PerformanceChartView()
}
