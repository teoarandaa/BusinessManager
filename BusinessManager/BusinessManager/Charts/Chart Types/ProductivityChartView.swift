import SwiftUI
import SwiftData
import Charts

struct ProductivityChartView: View {
    @Query var reports: [Report] // Obtiene los datos almacenados en SwiftData
    @State private var searchText = "" // Añadir propiedad de estado para el texto de búsqueda

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
    
    var filteredChartData: [ChartData] {
        if searchText.isEmpty {
            return chartData
        } else {
            return chartData.filter { $0.departmentName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: filteredChartData, by: { $0.departmentName })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    if let departmentData = groupedReports[department], !departmentData.isEmpty {
                        VStack(spacing: 35) {
                            Text(department)
                                .font(.title)
                                .bold()
                                .padding()
                            
                            Chart(departmentData) { data in
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
        .searchable(text: $searchText)
    }
}

#Preview {
    ProductivityChartView()
}
