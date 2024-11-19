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
        reports.map { ChartData(from: $0) }
    }

    var body: some View {
        Chart(chartData) { data in
            LineMark(
                x: .value("Date", data.date),
                y: .value("Performance", data.performanceMark)
            )
            .foregroundStyle(by: .value("Department", data.departmentName))
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
        .navigationTitle("Performance")
    }
}

#Preview {
    ProductivityChartView()
}
