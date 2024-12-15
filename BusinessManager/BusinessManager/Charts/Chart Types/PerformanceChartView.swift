import SwiftUI
import SwiftData
import Charts

struct PerformanceChartView: View {
    @Query var reports: [Report] // Recupera los datos almacenados en SwiftData
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
        ZStack {
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
            
            if !searchText.isEmpty && groupedReports.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .searchable(text: $searchText, prompt: "Search departments") // Añadir la barra de búsqueda
    }
}

#Preview {
    PerformanceChartView()
}
