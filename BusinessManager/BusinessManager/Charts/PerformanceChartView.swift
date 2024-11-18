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
    @Query var reports: [Report] // Obtiene los datos almacenados en SwiftData

    var chartData: [ChartData] {
        reports.map { ChartData(from: $0) } // Convierte los datos de Report a ChartData
    }

    var body: some View {
        Chart(chartData) { data in
            LineMark(
                x: .value("Date", data.date),
                y: .value("Performance", data.performanceMark)
            )
            .foregroundStyle(by: .value("Department", data.departmentName))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) // Configura el eje X con marcas mensuales
        }
        .chartYAxis {
            AxisMarks() // Configura el eje Y con marcas automáticas
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding()
        .navigationTitle("Performance")
    }
}

#Preview {
    PerformanceChartView()
}
