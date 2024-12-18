import SwiftUI
import SwiftData
import Charts

struct ProductivityChartView: View {
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
            .sorted(by: { $0.date < $1.date })
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
                                        x: .value("Date", data.date),
                                        y: .value("Performance", data.performanceMark)
                                    )
                                    .foregroundStyle(Color.accentColor)
                                    .symbol(by: .value("Department", data.departmentName))
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
