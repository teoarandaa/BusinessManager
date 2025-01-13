import SwiftUI
import SwiftData
import Charts

struct YearChartsView: View {
    let year: Int
    let data: [ChartData]
    let reports: [Report]
    
    // Define colors for each month
    let monthColors: [Int: Color] = [
        1: .red, 2: .orange, 3: .yellow, 4: .green,
        5: .blue, 6: .purple, 7: .pink, 8: .teal,
        9: .brown, 10: .cyan, 11: .indigo, 12: .mint
    ]
    
    @State private var isShowingYearlySummary = false
    
    // Procesar los datos para agrupar por día
    var processedData: [ChartData] {
        // Primero agrupamos por departamento
        let reportsByDepartment = Dictionary(grouping: data) { $0.departmentName }
        
        var result: [ChartData] = []
        
        // Para cada departamento, agrupamos por día
        for (_, departmentData) in reportsByDepartment {
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: departmentData) { data in
                calendar.startOfDay(for: data.date)
            }
            
            // Procesamos cada día
            for (date, dailyData) in groupedByDay {
                // Calcular promedios
                let avgPerformance = dailyData.reduce(0) { $0 + $1.performanceMark } / dailyData.count
                let avgVolume = dailyData.reduce(0) { $0 + $1.volumeOfWorkMark } / dailyData.count
                let totalTasks = dailyData.reduce(0) { $0 + $1.numberOfFinishedTasks }
                
                result.append(ChartData(
                    date: date,
                    departmentName: dailyData[0].departmentName,
                    performanceMark: avgPerformance,
                    volumeOfWorkMark: avgVolume,
                    numberOfFinishedTasks: totalTasks
                ))
            }
        }
        
        return result.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                // Productivity Chart
                VStack(spacing: 20) {
                    Text("productivity".localized())
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Chart {
                        ForEach(processedData) { data in
                            LineMark(
                                x: .value("date".localized(), data.date),
                                y: .value("performance".localized(), data.performanceMark)
                            )
                            .foregroundStyle(by: .value("department".localized(), data.departmentName))
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
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                // Workload Chart
                VStack(spacing: 20) {
                    Text("workload".localized())
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Chart(processedData) { data in
                        PointMark(
                            x: .value("volume_of_work".localized(), data.volumeOfWorkMark),
                            y: .value("performance".localized(), data.performanceMark)
                        )
                        .foregroundStyle(monthColors[Calendar.current.component(.month, from: data.date)] ?? .black)
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

                    // Legend
                    HStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(1..<13) { month in
                                HStack {
                                    Circle()
                                        .fill(monthColors[month] ?? .black)
                                        .frame(width: 10, height: 10)
                                    Text(DateFormatter().monthSymbols[month - 1].capitalized)
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(String(format: "charts_for".localized(), String(year)))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingYearlySummary = true
                } label: {
                    Label("yearly_summary".localized(), systemImage: "calendar.badge.clock")
                }
                .tint(.red)
            }
        }
        .sheet(isPresented: $isShowingYearlySummary) {
            YearlySummaryView(year: year, reports: reports)
        }
    }
}

#Preview {
    YearChartsView(year: 2024, data: [], reports: [])
} 
