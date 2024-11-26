import SwiftUI
import SwiftData
import Charts

struct YearChartsView: View {
    let year: Int
    let data: [ChartData]
    
    // Define colors for each month
    let monthColors: [Int: Color] = [
        1: .red, 2: .orange, 3: .yellow, 4: .green,
        5: .blue, 6: .purple, 7: .pink, 8: .teal,
        9: .brown, 10: .cyan, 11: .indigo, 12: .mint
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                // Performance Chart with both BarMarks
                Chart {
                    ForEach(data) { data in
                        BarMark(
                            x: .value("Department", data.departmentName),
                            y: .value("Volume of Work", data.volumeOfWorkMark)
                        )
                        .foregroundStyle(Color.accentColor)
                        .position(by: .value("Category", "Volume of Work"))
                    }
                    
                    ForEach(data) { data in
                        BarMark(
                            x: .value("Department", data.departmentName),
                            y: .value("Tasks Completed", data.numberOfFinishedTasks)
                        )
                        .foregroundStyle(Color.blue)
                        .position(by: .value("Category", "Tasks Completed"))
                    }
                }
                .chartXAxis {
                    AxisMarks()
                }
                .chartYAxis {
                    AxisMarks()
                }
                .aspectRatio(1.0, contentMode: .fit)
                .padding()
                
                // Productivity Chart
                Chart {
                    ForEach(data) { data in
                        LineMark(
                            x: .value("Month", data.date, unit: .month),
                            y: .value("Performance", data.performanceMark)
                        )
                        .foregroundStyle(by: .value("Department", data.departmentName))
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
                
                // Workload Chart
                Chart(data) { data in
                    PointMark(
                        x: .value("Department", data.departmentName),
                        y: .value("Performance", data.performanceMark)
                    )
                    .foregroundStyle(monthColors[Calendar.current.component(.month, from: data.date)] ?? .black)
                    .symbol(by: .value("Department", data.departmentName))
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
                                Text(DateFormatter().monthSymbols[month - 1])
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensures the grid takes the full width of the chart
                }
                .padding(.top, 5)
            }
        }
        .navigationTitle("Charts for \(year)")
    }
}

#Preview {
    YearChartsView(year: 2024, data: [])
} 
