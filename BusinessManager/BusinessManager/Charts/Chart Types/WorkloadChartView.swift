import SwiftUI
import SwiftData
import Charts

struct WorkloadChartView: View {
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
            for (_, dailyReports) in groupedByDay {
                let summary = DailyReportSummary.fromReports(dailyReports)
                result.append(ChartData(
                    date: summary.date,
                    departmentName: summary.departmentName,
                    performanceMark: summary.performanceMark,
                    volumeOfWorkMark: summary.volumeOfWorkMark,
                    numberOfFinishedTasks: summary.numberOfFinishedTasks
                ))
            }
        }
        
        return result
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
                            Chart(departmentData) { data in
                                PointMark(
                                    x: .value("volume_of_work".localized(), data.volumeOfWorkMark),
                                    y: .value("performance".localized(), data.performanceMark)
                                )
                                .foregroundStyle(Color.accentColor)
                                .symbol(by: .value("department".localized(), data.departmentName))
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
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    WorkloadChartView()
}
