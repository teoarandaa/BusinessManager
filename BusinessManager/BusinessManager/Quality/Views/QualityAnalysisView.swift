import SwiftUI
import SwiftData
import Charts

struct QualityAnalysisView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Report.date) private var reports: [Report]
    @Query(sort: \QualityMetric.date) private var metrics: [QualityMetric]
    @Query(sort: \QualityInsight.date) private var insights: [QualityInsight]
    
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedDepartment: String?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
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
                                ForEach(Array(filteredMetrics.prefix(2))) { metric in
                                    QualityMetricCard(metric: metric)
                                }
                            }
                            
                            if filteredMetrics.count > 2 {
                                GridRow {
                                    QualityMetricCard(metric: filteredMetrics[2])
                                        .gridCellColumns(2)
                                }
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
                        
                        ErrorDistributionChart(reports: filterReportsByTimeFrame())
                        DelayPatternView(reports: filterReportsByTimeFrame())
                    }
                    .padding(.horizontal)
                    
                    // Insights
                    if !filteredInsights.isEmpty {
                        VStack(spacing: 16) {
                            Text("Quality Insights")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(filteredInsights) { insight in
                                QualityInsightCard(insight: insight)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Quality Analysis")
            .onChange(of: reports) { oldReports, newReports in
                // Primero eliminamos las métricas y insights antiguos
                cleanupOldData()
                // Luego generamos las nuevas métricas
                generateMetricsIfNeeded()
            }
        }
    }
    
    private func cleanupOldData() {
        // Obtener los IDs de reportes actuales
        let currentReportIds = Set(reports.map(\.id))
        
        // Obtener los departamentos actuales
        let currentDepartments = Set(reports.map(\.departmentName))
        
        // Eliminar métricas huérfanas
        let orphanedMetrics = metrics.filter { metric in
            guard let report = metric.report else { return true }
            return !currentReportIds.contains(report.id)
        }
        
        for metric in orphanedMetrics {
            context.delete(metric)
        }
        
        // Eliminar insights de departamentos eliminados
        let orphanedInsights = insights.filter { insight in
            !currentDepartments.contains(insight.department)
        }
        
        for insight in orphanedInsights {
            context.delete(insight)
        }
        
        // Resetear el departamento seleccionado si ya no existe
        if let selectedDepartment = selectedDepartment,
           !currentDepartments.contains(selectedDepartment) {
            self.selectedDepartment = nil
        }
        
        try? context.save()
    }
    
    private func generateMetricsIfNeeded() {
        let reportsWithoutMetrics = reports.filter { report in
            !metrics.contains { metric in
                Calendar.current.isDate(metric.date, equalTo: report.date, toGranularity: .day) &&
                metric.report?.id == report.id
            }
        }
        
        for report in reportsWithoutMetrics {
            // Performance Metric
            let performanceMetric = QualityMetric(
                date: report.date,
                name: "Performance",
                value: Double(report.performanceMark),
                target: 85,
                trend: calculateTrend(for: report.departmentName),
                impact: .high,
                report: report
            )
            
            // Volume Metric
            let volumeMetric = QualityMetric(
                date: report.date,
                name: "Volume",
                value: Double(report.volumeOfWorkMark),
                target: 90,
                trend: calculateTrend(for: report.departmentName),
                impact: .medium,
                report: report
            )
            
            // Task Completion Metric
            let completionRate = report.tasksCompletedWithoutDelay > 0 
                ? (Double(report.tasksCompletedWithoutDelay) / Double(report.totalTasksCreated)) * 100 
                : 0
            let completionMetric = QualityMetric(
                date: report.date,
                name: "Task Completion",
                value: completionRate,
                target: 95,
                trend: calculateTrend(for: report.departmentName),
                impact: .high,
                report: report
            )
            
            context.insert(performanceMetric)
            context.insert(volumeMetric)
            context.insert(completionMetric)
        }
        
        try? context.save()
    }
    
    private func generateInsightsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        // Limpiar insights antiguos no resueltos
        let oldInsights = insights.filter { insight in
            let daysSinceCreation = calendar.dateComponents([.day], from: insight.date, to: today).day ?? 0
            return daysSinceCreation > 30 && !insight.isResolved
        }
        
        oldInsights.forEach { context.delete($0) }
        
        // Analizar métricas recientes
        let recentMetrics = metrics.filter { metric in
            let daysSinceCreation = calendar.dateComponents([.day], from: metric.date, to: today).day ?? 0
            return daysSinceCreation <= 7
        }
        
        let departments = Set(recentMetrics.compactMap { $0.report?.departmentName })
        
        for department in departments {
            let departmentMetrics = recentMetrics.filter { $0.report?.departmentName == department }
            
            // Analizar performance
            if let avgPerformance = departmentMetrics
                .filter({ $0.name == "Performance" })
                .map({ $0.value })
                .average,
               avgPerformance < 70 {
                createInsightIfNeeded(
                    title: "Low Performance Alert",
                    description: "Department \(department) shows consistently low performance (avg: \(Int(avgPerformance))%)",
                    department: department,
                    type: .performance
                )
            }
            
            // Analizar volume
            if let avgVolume = departmentMetrics
                .filter({ $0.name == "Volume" })
                .map({ $0.value })
                .average,
               avgVolume < 75 {
                createInsightIfNeeded(
                    title: "Volume Concerns",
                    description: "Work volume in \(department) is below target (avg: \(Int(avgVolume))%)",
                    department: department,
                    type: .volume
                )
            }
            
            // Analizar delays
            if let avgCompletion = departmentMetrics
                .filter({ $0.name == "Task Completion" })
                .map({ $0.value })
                .average,
               avgCompletion < 80 {
                createInsightIfNeeded(
                    title: "Delay Pattern Detected",
                    description: "High delay rate in \(department) (completion rate: \(Int(avgCompletion))%)",
                    department: department,
                    type: .delay
                )
            }
        }
        
        try? context.save()
    }
    
    private func createInsightIfNeeded(
        title: String,
        description: String,
        department: String,
        type: QualityInsight.InsightType
    ) {
        // Verificar si ya existe un insight similar no resuelto
        let existingSimilarInsight = insights.first {
            $0.department == department &&
            $0.type == type &&
            !$0.isResolved &&
            Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .day)
        }
        
        guard existingSimilarInsight == nil else { return }
        
        let insight = QualityInsight(
            title: title,
            description: description,
            department: department,
            type: type
        )
        
        context.insert(insight)
    }
    
    private func calculateTrend(for department: String) -> QualityMetric.MetricTrend {
        let departmentMetrics = metrics
            .filter { $0.report?.departmentName == department }
            .sorted { $0.date < $1.date }
        
        guard departmentMetrics.count >= 2 else { return .stable }
        
        let recentMetrics = Array(departmentMetrics.suffix(5))
        let firstHalf = recentMetrics.prefix(recentMetrics.count / 2)
        let secondHalf = recentMetrics.suffix(recentMetrics.count / 2)
        
        let firstAvg = firstHalf.reduce(0.0) { $0 + $1.value } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0.0) { $0 + $1.value } / Double(secondHalf.count)
        
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
    
    var filteredMetrics: [QualityMetric] {
        let timeFilteredMetrics = metrics.filter { isInSelectedTimeFrame(date: $0.date) }
        
        if selectedDepartment == nil {
            // Media de todos los departamentos
            let performanceAvg = timeFilteredMetrics
                .filter { $0.name == "Performance" }
                .map { $0.value }
                .average ?? 0
            
            let volumeAvg = timeFilteredMetrics
                .filter { $0.name == "Volume" }
                .map { $0.value }
                .average ?? 0
            
            let completionAvg = timeFilteredMetrics
                .filter { $0.name == "Task Completion" }
                .map { $0.value }
                .average ?? 0
            
            return [
                QualityMetric(
                    date: .now,
                    name: "Performance",
                    value: performanceAvg,
                    target: 85,
                    trend: calculateOverallTrend(for: "Performance", in: timeFilteredMetrics),
                    impact: .high
                ),
                QualityMetric(
                    date: .now,
                    name: "Volume",
                    value: volumeAvg,
                    target: 90,
                    trend: calculateOverallTrend(for: "Volume", in: timeFilteredMetrics),
                    impact: .medium
                ),
                QualityMetric(
                    date: .now,
                    name: "Task Completion",
                    value: completionAvg,
                    target: 95,
                    trend: calculateOverallTrend(for: "Task Completion", in: timeFilteredMetrics),
                    impact: .high
                )
            ]
        } else {
            // Media de un departamento específico
            return timeFilteredMetrics
                .filter { $0.report?.departmentName.lowercased() == selectedDepartment?.lowercased() }
                .reduce(into: [String: [QualityMetric]]()) { dict, metric in
                    dict[metric.name, default: []].append(metric)
                }
                .map { name, metrics in
                    let avgValue = metrics.map(\.value).average ?? 0
                    return QualityMetric(
                        date: .now,
                        name: name,
                        value: avgValue,
                        target: metrics.first?.target ?? 0,
                        trend: calculateOverallTrend(for: name, in: metrics),
                        impact: metrics.first?.impact ?? .medium
                    )
                }
        }
    }
    
    private func calculateOverallTrend(for metricName: String, in metrics: [QualityMetric]) -> QualityMetric.MetricTrend {
        let sortedMetrics = metrics
            .filter { $0.name == metricName }
            .sorted { $0.date < $1.date }
        
        guard sortedMetrics.count >= 2 else { return .stable }
        
        let firstHalf = Array(sortedMetrics.prefix(sortedMetrics.count / 2))
        let secondHalf = Array(sortedMetrics.suffix(sortedMetrics.count / 2))
        
        let firstAvg = firstHalf.map(\.value).average ?? 0
        let secondAvg = secondHalf.map(\.value).average ?? 0
        
        if secondAvg > firstAvg * 1.05 {
            return .improving
        } else if secondAvg < firstAvg * 0.95 {
            return .declining
        }
        return .stable
    }
    
    var filteredInsights: [QualityInsight] {
        insights.filter { insight in
            let isInTimeFrame = isInSelectedTimeFrame(date: insight.date)
            let isInDepartment = selectedDepartment == nil || 
                insight.department.lowercased() == selectedDepartment?.lowercased()
            return isInTimeFrame && isInDepartment && !insight.isResolved
        }
    }
    
    private func filterReportsByTimeFrame() -> [Report] {
        reports.filter { report in
            let isInTimeFrame = isInSelectedTimeFrame(date: report.date)
            let isInDepartment = selectedDepartment == nil || 
                report.departmentName.lowercased() == selectedDepartment?.lowercased()
            return isInTimeFrame && isInDepartment
        }
    }
} 