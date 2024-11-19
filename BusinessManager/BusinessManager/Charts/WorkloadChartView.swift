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
    @Query var reports: [Report] // Obtiene los datos almacenados en SwiftData
    
    var chartData: [ChartData] {
        reports.map { ChartData(from: $0) }
    }
    
    // Agrupa los datos por departamento
    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: chartData, by: { $0.departmentName })
    }

    var body: some View {
        ScrollView { // Hacemos que todo el contenido sea desplazable
            VStack(spacing: 20) { // Espaciado entre los gráficos
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack {
                        // Título con el nombre del departamento
                        Text(department)
                            .font(.title)
                            .padding()
                        
                        // Gráfico de dispersión para cada departamento
                        Chart(groupedReports[department]!) { data in
                            PointMark(
                                x: .value("Volume of Work", data.volumeOfWorkMark), // Eje X: porcentaje de volumen de trabajo
                                y: .value("Performance", data.performanceMark) // Eje Y: porcentaje de productividad
                            )
                            .foregroundStyle(by: .value("Department", data.departmentName)) // Estilo por departamento
                            .symbol(by: .value("Department", data.departmentName)) // Símbolo por departamento
                        }
                        .chartXAxis {
                            AxisMarks() // Marcas en el eje X
                        }
                        .chartYAxis {
                            AxisMarks() // Marcas en el eje Y
                        }
                        .aspectRatio(1.0, contentMode: .fit) // Mantener la proporción del gráfico
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Performance by Department") // Título de la vista
    }
}

#Preview {
    WorkloadChartView()
}
