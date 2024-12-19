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
    @State private var showingThresholds = false
    @State private var showingInfo = false
    @State private var showingSettings = false
    
    @AppStorage("minPerformance") private var minPerformance: Double = 70
    @AppStorage("minTaskCompletion") private var minTaskCompletion: Double = 75
    @AppStorage("minVolumeOfWork") private var minVolumeOfWork: Double = 65
    
    @Binding var selectedTab: Int
    
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
            Group {
                if reports.isEmpty {
                    ContentUnavailableView(label: {
                        Label("no_quality_data".localized(), systemImage: "checkmark.seal")
                            .font(.title2)
                    }, description: {
                        Text("start_adding_reports_quality".localized())
                            .foregroundStyle(.secondary)
                    }, actions: {
                        Button("reports".localized()) {
                            selectedTab = 0
                        }
                    })
                    .padding(.bottom, 115)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Métricas
                            VStack(spacing: 16) {
                                Text("key_metrics".localized())
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                                    GridRow {
                                        MetricView(
                                            title: "performance".localized(),
                                            value: averagePerformance,
                                            trend: performanceTrend,
                                            threshold: minPerformance
                                        )
                                        MetricView(
                                            title: "volume".localized(),
                                            value: averageVolume,
                                            trend: volumeTrend,
                                            threshold: minVolumeOfWork
                                        )
                                    }
                                    
                                    GridRow {
                                        MetricView(
                                            title: "task_completion".localized(),
                                            value: averageCompletion,
                                            trend: completionTrend,
                                            threshold: minTaskCompletion
                                        )
                                        .gridCellColumns(2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Analytics
                            VStack(spacing: 16) {
                                Text("analytics".localized())
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
                }
            }
            .navigationTitle("quality_analysis".localized())
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("settings".localized(), systemImage: "gear")
                    }
                    Button {
                        showingInfo = true
                    } label: {
                        Label("information".localized(), systemImage: "info.circle")
                    }
                }
                
                // Trailing Items (Right side)
                if !reports.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            // Time Frame Picker
                            Picker("time_frame".localized(), selection: $selectedTimeFrame) {
                                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                                    Label(timeFrame.rawValue, systemImage: timeFrame.systemImage)
                                        .tag(timeFrame)
                                }
                            }
                            
                            Divider()
                            
                            // Department Picker
                            Menu("department".localized()) {
                                Button("all_departments".localized()) {
                                    selectedDepartment = nil
                                }
                                
                                Divider()
                                
                                ForEach(Array(Set(reports.map(\.departmentName))).sorted(), id: \.self) { department in
                                    Button(department) {
                                        selectedDepartment = department
                                    }
                                    .foregroundStyle(selectedDepartment == department ? .blue : .primary)
                                }
                            }
                        } label: {
                            Label("filter".localized(), systemImage: "line.3.horizontal.decrease.circle")
                        }
                        
                        Button {
                            showingThresholds.toggle()
                        } label: {
                            Label("thresholds".localized(), systemImage: "slider.horizontal.3")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingInfo) {
                QualityInfoSheetView()
                    .presentationDetents([.height(700)])
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingThresholds) {
                ThresholdsSettingsView(
                    minPerformance: $minPerformance,
                    minTaskCompletion: $minTaskCompletion,
                    minVolumeOfWork: $minVolumeOfWork
                )
            }
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

#Preview {
    QualityAnalysisView(selectedTab: .constant(0))
}

// MARK: - ThresholdsSettingsView
private struct ThresholdsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var minPerformance: Double
    @Binding var minTaskCompletion: Double
    @Binding var minVolumeOfWork: Double
    
    var body: some View {
        NavigationStack {
            Form {
                Section("minimum_thresholds".localized()) {
                    VStack(alignment: .leading) {
                        Text(String(format: "performance_value".localized(), Int(minPerformance)))
                        Slider(value: $minPerformance, in: 0...100, step: 5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(String(format: "task_completion_value".localized(), Int(minTaskCompletion)))
                        Slider(value: $minTaskCompletion, in: 0...100, step: 5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(String(format: "volume_work_value".localized(), Int(minVolumeOfWork)))
                        Slider(value: $minVolumeOfWork, in: 0...100, step: 5)
                    }
                }
            }
            .navigationTitle("thresholds_settings".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - MetricView
private struct MetricView: View {
    let title: String
    let value: Double
    let trend: QualityMetric.MetricTrend
    let threshold: Double
    
    private var valueColor: Color {
        value >= threshold ? .green : .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text("\(Int(value))%")
                .font(.title)
                .bold()
                .foregroundStyle(valueColor)
            
            Label(trendText, systemImage: trendIcon)
                .font(.caption)
                .foregroundStyle(trendColor)
            
            Text(String(format: "min_value".localized(), Int(threshold)))
                .font(.caption2)
                .foregroundStyle(.secondary)
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
        case .improving: return "improving".localized()
        case .stable: return "stable".localized()
        case .declining: return "declining".localized()
        }
    }
} 
