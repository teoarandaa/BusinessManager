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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                // Add a button for Yearly Summary
                NavigationLink(destination: YearlySummaryView(year: year, reports: reports)) {
                    Text("Yearly Summary")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity)
                .padding()

                // Performance Chart with both BarMarks
                Text("Performance")
                    .font(.title)
                    .bold()
                    .padding()
                
                Chart {
                    let groupedData = Dictionary(grouping: data, by: { $0.departmentName })
                    
                    ForEach(groupedData.keys.sorted(), id: \.self) { department in
                        if let departmentData = groupedData[department] {
                            let totalVolume = departmentData.reduce(0) { $0 + $1.volumeOfWorkMark }
                            let averageVolume = departmentData.isEmpty ? 0 : Double(totalVolume) / Double(departmentData.count)
                            
                            BarMark(
                                x: .value("Department", department),
                                y: .value("Average Volume of Work", averageVolume)
                            )
                            .foregroundStyle(Color.accentColor)
                            .position(by: .value("Category", "Average Volume of Work"))
                        }
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
                Text("Productivity")
                    .font(.title)
                    .bold()
                    .padding()
                Chart {
                    ForEach(data) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Performance", data.performanceMark)
                        )
                        .foregroundStyle(by: .value("Department", data.departmentName))
                        .symbol(by: .value("Department", data.departmentName))
                        
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Performance", data.performanceMark)
                        )
                        .foregroundStyle(by: .value("Department", data.departmentName))
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
                Text("Workload")
                    .font(.title)
                    .bold()
                    .padding()
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
    YearChartsView(year: 2024, data: [], reports: [])
} 
