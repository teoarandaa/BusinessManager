//
//  ProductivityChartView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 17/11/24.
//

import SwiftUI
import SwiftData
import Charts

struct ProductivityChartView: View {
    @Query var reports: [Report] // Obtiene los datos almacenados en SwiftData

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
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("Performance", data.performanceMark)
                            )
                            .foregroundStyle(Color.accentColor)
                            .symbol(by: .value("Department", data.departmentName))
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month))
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
    ProductivityChartView()
}
