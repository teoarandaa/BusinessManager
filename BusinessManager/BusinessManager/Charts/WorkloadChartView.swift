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
    @State private var searchText = ""
    
    var chartData: [ChartData] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        return reports
            .filter {
                let reportYear = Calendar.current.component(.year, from: $0.date)
                let reportMonth = Calendar.current.component(.month, from: $0.date)
                return reportYear == currentYear && reportMonth == currentMonth
            }
            .map { ChartData(from: $0) }
    }
    
    var filteredChartData: [ChartData] {
        if searchText.isEmpty {
            return chartData
        } else {
            return chartData.filter { $0.departmentName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: filteredChartData, by: { $0.departmentName })
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
        .searchable(text: $searchText)
    }
}

#Preview {
    WorkloadChartView()
}
