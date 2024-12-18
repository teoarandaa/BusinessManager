import SwiftUI
import SwiftData
import Charts

struct PerformanceChartView: View {
    @Query var reports: [Report]
    
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
            VStack(spacing: 35) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack(spacing: 20) {
                        Text(department)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        if let departmentData = groupedReports[department] {
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
                            
                            Chart {
                                BarMark(
                                    x: .value("Month", departmentData.first?.date ?? Date(), unit: .month),
                                    y: .value("Volume of Work", departmentData.first?.volumeOfWorkMark ?? 0)
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
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

#Preview {
    PerformanceChartView()
}
