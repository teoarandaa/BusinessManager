import SwiftUI
import SwiftData
import Charts

extension Array where Element == Int {
    var average: Double {
        guard !isEmpty else { return 0 }
        return Double(reduce(0, +)) / Double(count)
    }
}

struct QualityAnalysisView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Report.date) private var reports: [Report]
    
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedDepartment: String?
    
    private var filteredReports: [Report] {
        reports.filter { report in
            let isInTimeFrame = isInSelectedTimeFrame(date: report.date)
            let isInDepartment = selectedDepartment == nil || 
                report.departmentName.lowercased() == selectedDepartment?.lowercased()
            return isInTimeFrame && isInDepartment
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Filtros
                    QualityAnalysisFilterMenu(
                        selectedTimeFrame: $selectedTimeFrame,
                        selectedDepartment: $selectedDepartment,
                        departments: Array(Set(reports.map(\.departmentName)))
                    )
                    .padding(.horizontal)
                    
                    // Métricas
                    VStack(spacing: 16) {
                        Text("Key Metrics")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                            GridRow {
                                MetricView(
                                    title: "Performance",
                                    value: averagePerformance,
                                    trend: performanceTrend
                                )
                                MetricView(
                                    title: "Volume",
                                    value: averageVolume,
                                    trend: volumeTrend
                                )
                            }
                            
                            GridRow {
                                MetricView(
                                    title: "Task Completion",
                                    value: averageCompletion,
                                    trend: completionTrend
                                )
                                .gridCellColumns(2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Analytics
                    VStack(spacing: 16) {
                        Text("Analytics")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ErrorDistributionChart(reports: filteredReports)
                        DelayPatternView(reports: filteredReports)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Quality Analysis")
        }
    }
    
    // MARK: - Computed Properties
    
    private var averagePerformance: Double {
        filteredReports.map(\.performanceMark).average
    }
    
    private var averageVolume: Double {
        filteredReports.map(\.volumeOfWorkMark).average
    }
    
    private var averageCompletion: Double {
        let completed = Double(filteredReports.reduce(0) { $0 + $1.tasksCompletedWithoutDelay })
        let total = Double(filteredReports.reduce(0) { $0 + $1.totalTasksCreated })
        guard total > 0 else { return 0 }
        return (completed / total) * 100
    }
    
    private var performanceTrend: QualityMetric.MetricTrend {
        calculateTrend(values: filteredReports.map(\.performanceMark))
    }
    
    private var volumeTrend: QualityMetric.MetricTrend {
        calculateTrend(values: filteredReports.map(\.volumeOfWorkMark))
    }
    
    private var completionTrend: QualityMetric.MetricTrend {
        calculateTrend(values: filteredReports.map { report in
            guard report.totalTasksCreated > 0 else { return 0 }
            return Double(report.tasksCompletedWithoutDelay) / Double(report.totalTasksCreated) * 100
        })
    }
    
    // MARK: - Helper Functions
    
    private func calculateTrend(values: [Int]) -> QualityMetric.MetricTrend {
        calculateTrend(values: values.map(Double.init))
    }
    
    private func calculateTrend(values: [Double]) -> QualityMetric.MetricTrend {
        guard values.count >= 2 else { return .stable }
        
        let firstHalf = Array(values.prefix(values.count / 2))
        let secondHalf = Array(values.suffix(values.count / 2))
        
        let firstAvg = firstHalf.reduce(0.0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0.0, +) / Double(secondHalf.count)
        
        if secondAvg > firstAvg * 1.05 {
            return .improving
        } else if secondAvg < firstAvg * 0.95 {
            return .declining
        }
        return .stable
    }
    
    private func isInSelectedTimeFrame(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return date >= weekStart && date < weekEnd
            
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return date >= monthStart && date < monthEnd
            
        case .quarter:
            let quarter = (calendar.component(.month, from: now) - 1) / 3
            let quarterStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarter * 3 + 1))!
            let quarterEnd = calendar.date(byAdding: .month, value: 3, to: quarterStart)!
            return date >= quarterStart && date < quarterEnd
            
        case .year:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart)!
            return date >= yearStart && date < yearEnd
        }
    }
}

// MARK: - MetricView
private struct MetricView: View {
    let title: String
    let value: Double
    let trend: QualityMetric.MetricTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text("\(Int(value))%")
                .font(.title)
                .bold()
            
            Label(trendText, systemImage: trendIcon)
                .font(.caption)
                .foregroundStyle(trendColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var trendColor: Color {
        switch trend {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .red
        }
    }
    
    private var trendIcon: String {
        switch trend {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "equal.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    private var trendText: String {
        switch trend {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
} 