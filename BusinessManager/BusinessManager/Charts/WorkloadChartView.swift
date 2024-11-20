//
//  WorkloadChartView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 17/11/24.
//

import SwiftUI
import SwiftData
import Charts

struct WorkloadChartView: View {
    @Query var reports: [Report]
    
    var chartData: [ChartData] {
        reports.map { ChartData(from: $0) }
    }
    
    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: chartData, by: { $0.departmentName })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack {
                        Text(department)
                            .font(.title)
                            .bold()
                            .padding()
                        
                        Chart(groupedReports[department]!) { data in
                            PointMark(
                                x: .value("Volume of Work", data.volumeOfWorkMark),
                                y: .value("Performance", data.performanceMark)
                            )
                            .foregroundStyle(by: .value("Department", data.departmentName))
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
                    }
                }
            }
        }
        .navigationTitle("Performance by Department")
    }
}

#Preview {
    WorkloadChartView()
}
