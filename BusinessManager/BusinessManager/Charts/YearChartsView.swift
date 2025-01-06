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
                        let sortedData = data.sorted(by: { $0.date < $1.date })
                        
                        ForEach(sortedData) { data in
                            LineMark(
                                x: .value("date".localized(), data.date),
                                y: .value("performance".localized(), data.performanceMark)
                            )
                            .foregroundStyle(by: .value("department".localized(), data.departmentName))
                            .symbol(by: .value("department".localized(), data.departmentName))
                            
                            PointMark(
                                x: .value("date".localized(), data.date),
                                y: .value("performance".localized(), data.performanceMark)
                            )
                            .foregroundStyle(by: .value("department".localized(), data.departmentName))
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
                    
                    Chart(data) { data in
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
