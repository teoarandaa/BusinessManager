import SwiftUI
import SwiftData
import Charts

struct YearChartsView: View {
    let year: Int
    let data: [ChartData]
    
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
                    .foregroundStyle(Color.accentColor)
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
            }
        }
        .navigationTitle("Charts for \(year)")
    }
}

#Preview {
    YearChartsView(year: 2024, data: [])
} 
