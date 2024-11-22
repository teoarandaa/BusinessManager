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
                        
                        Chart {
                            // Barras para el Volumen de Trabajo
                            ForEach(groupedReports[department]!) { data in
                                BarMark(
                                    x: .value("Month", data.date, unit: .month),
                                    y: .value("Volume of Work", data.volumeOfWorkMark)
                                )
                                .foregroundStyle(.blue)
                            }
                            
                            // Barras para las Tareas Completadas
                            ForEach(groupedReports[department]!) { data in
                                BarMark(
                                    x: .value("Month", data.date, unit: .month),
                                    y: .value("Tasks Completed", data.numberOfFinishedTasks)
                                )
                                .foregroundStyle(.orange)
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
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                            Text("Volume of Work")
                                .font(.caption)
                            
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                            Text("Tasks Completed")
                                .font(.caption)
                        }
                        .padding(.top, 5)
                    }
                }
            }
        }
        .navigationTitle("Performance by Department")
    }
}

#Preview {
    PerformanceChartView()
}
