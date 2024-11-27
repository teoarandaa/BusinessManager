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
    let currentYear = Calendar.current.component(.year, from: Date())
    return reports
        .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
        .map { ChartData(from: $0) }
    }
    
    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: chartData, by: { $0.departmentName })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack(spacing: 35) {
                        Text(department)
                            .font(.title)
                            .bold()
                            .padding()
                        
                        Chart(groupedReports[department]!) { data in
                            PointMark(
                                x: .value("Volume of Work", data.volumeOfWorkMark),
                                y: .value("Performance", data.performanceMark)
                            )
                            .foregroundStyle(Color.accentColor)
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
    }
}

#Preview {
    WorkloadChartView()
}
