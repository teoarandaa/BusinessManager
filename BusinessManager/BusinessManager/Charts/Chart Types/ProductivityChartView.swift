import SwiftUI
import SwiftData
import Charts

struct ProductivityChartView: View {
    @Query var reports: [Report]

    var chartData: [ChartData] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // Primero filtramos por año y mes
        let filteredReports = reports.filter {
            let reportYear = Calendar.current.component(.year, from: $0.date)
            let reportMonth = Calendar.current.component(.month, from: $0.date)
            return reportYear == currentYear && reportMonth == currentMonth
        }
        
        // Primero agrupamos por departamento
        let reportsByDepartment = Dictionary(grouping: filteredReports) { $0.departmentName }
        
        var result: [ChartData] = []
        
        // Para cada departamento, agrupamos por día
        for (_, departmentReports) in reportsByDepartment {
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: departmentReports) { report in
                calendar.startOfDay(for: report.date)
            }
            
            // Procesamos cada día
            for (date, dailyReports) in groupedByDay {
                // Sumamos todas las tareas del día
                let totalTasksCreated = dailyReports.reduce(0) { $0 + $1.totalTasksCreated }
                let tasksCompletedOnTime = dailyReports.reduce(0) { $0 + $1.tasksCompletedWithoutDelay }
                let totalTasksCompleted = dailyReports.reduce(0) { $0 + $1.numberOfFinishedTasks }
                
                // Calculamos las métricas basadas en los totales
                let performanceMark = totalTasksCreated > 0 ? 
                    Double(tasksCompletedOnTime) / Double(totalTasksCreated) * 100 : 0
                let volumeOfWorkMark = totalTasksCreated > 0 ? 
                    Double(totalTasksCompleted) / Double(totalTasksCreated) * 100 : 0
                
                result.append(ChartData(
                    date: date,
                    departmentName: dailyReports[0].departmentName,
                    performanceMark: Int(round(performanceMark)),
                    volumeOfWorkMark: Int(round(volumeOfWorkMark)),
                    numberOfFinishedTasks: totalTasksCompleted
                ))
            }
        }
        
        return result.sorted(by: { $0.date < $1.date })
    }

    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: chartData, by: { $0.departmentName })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack(spacing: 20) {
                        Text(department)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        if let departmentData = groupedReports[department] {
                            Chart {
                                ForEach(departmentData) { data in
                                    LineMark(
                                        x: .value("date".localized(), data.date),
                                        y: .value("performance".localized(), data.performanceMark)
                                    )
                                    .foregroundStyle(Color.accentColor)
                                    .symbol(by: .value("department".localized(), data.departmentName))
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
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    ProductivityChartView()
}
