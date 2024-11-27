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
    @Query var reports: [Report] // Recupera los datos almacenados en SwiftData
    
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
                        
                        if let departmentData = groupedReports[department] {
                            // Calculate average volume of work
                            let totalVolume = departmentData.reduce(0) { $0 + $1.volumeOfWorkMark }
                            let averageVolume = departmentData.isEmpty ? 0 : Double(totalVolume) / Double(departmentData.count)
                            
                            Chart {
                                BarMark(
                                    x: .value("Month", departmentData.first?.date ?? Date(), unit: .month),
                                    y: .value("Volume of Work", averageVolume)
                                )
                                .foregroundStyle(Color.accentColor)
                                .position(by: .value("Category", "Volume of Work"))
                                
                                ForEach(departmentData) { data in
                                    BarMark(
                                        x: .value("Month", data.date, unit: .month),
                                        y: .value("Tasks Completed", data.numberOfFinishedTasks)
                                    )
                                    .foregroundStyle(Color.blue)
                                    .position(by: .value("Category", "Tasks Completed"))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .month)) {
                                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                                }
                            }
                            .chartYAxis {
                                AxisMarks()
                            }
                            .aspectRatio(1.0, contentMode: .fit)
                            .padding()
                            
                            // Leyenda
                            HStack {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 10, height: 10)
                                Text("Volume of Work")
                                    .font(.caption)
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 10, height: 10)
                                Text("Tasks Completed")
                                    .font(.caption)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PerformanceChartView()
}
