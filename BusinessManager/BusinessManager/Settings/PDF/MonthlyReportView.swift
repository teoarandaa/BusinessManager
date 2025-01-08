import SwiftUI
import PDFKit
import SwiftData
import Charts

// MARK: - Report Period Enum
enum ReportPeriod: String, CaseIterable {
    case month = "monthly"
    case quarter = "quarterly"
    case year = "yearly"
    
    var systemImage: String {
        switch self {
        case .month: return "calendar"
        case .quarter: return "calendar.badge.clock"
        case .year: return "calendar.badge.exclamationmark"
        }
    }
    
    var localizedName: String {
        rawValue.localized()
    }
}

// MARK: - Month Year Picker
struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onDateSelected: () -> Void
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let years = Array((2020...Calendar.current.component(.year, from: Date())).reversed())
    private let months = Calendar.current.monthSymbols
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping () -> Void) {
        _selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue) - 1)
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(0..<months.count, id: \.self) { index in
                        Text(months[index].capitalized).tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .onChange(of: selectedYear) { updateSelectedDate() }
            .onChange(of: selectedMonth) { updateSelectedDate() }
            .navigationTitle("select_month".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }
    
    private func updateSelectedDate() {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth + 1
        dateComponents.day = 1
        
        if let date = Calendar.current.date(from: dateComponents) {
            selectedDate = date
            onDateSelected()
        }
    }
}

// MARK: - Quarter Year Picker
struct QuarterYearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onDateSelected: () -> Void
    
    @State private var selectedYear: Int
    @State private var selectedQuarter: Int
    
    private let years = Array((2020...Calendar.current.component(.year, from: Date())).reversed())
    private let quarters = [
        "q1_range".localized(), // "Q1 (Ene-Mar)"
        "q2_range".localized(), // "Q2 (Abr-Jun)"
        "q3_range".localized(), // "Q3 (Jul-Sep)"
        "q4_range".localized()  // "Q4 (Oct-Dic)"
    ]
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping () -> Void) {
        _selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedQuarter = State(initialValue: (calendar.component(.month, from: selectedDate.wrappedValue) - 1) / 3)
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                Picker("Quarter", selection: $selectedQuarter) {
                    ForEach(0..<quarters.count, id: \.self) { index in
                        Text(quarters[index]).tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .onChange(of: selectedYear) { updateSelectedDate() }
            .onChange(of: selectedQuarter) { updateSelectedDate() }
            .navigationTitle("select_quarter".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }
    
    private func updateSelectedDate() {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = (selectedQuarter * 3) + 1
        dateComponents.day = 1
        
        if let date = Calendar.current.date(from: dateComponents) {
            selectedDate = date
            onDateSelected()
        }
    }
}

// MARK: - Year Picker
struct YearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onDateSelected: () -> Void
    
    @State private var selectedYear: Int
    
    private let years = Array((2020...Calendar.current.component(.year, from: Date())).reversed())
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping () -> Void) {
        _selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .padding()
            .onChange(of: selectedYear) { updateSelectedDate() }
            .navigationTitle("select_year".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }
    
    private func updateSelectedDate() {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = 1
        dateComponents.day = 1
        
        if let date = Calendar.current.date(from: dateComponents) {
            selectedDate = date
            onDateSelected()
        }
    }
}

// MARK: - Monthly Report View
struct MonthlyReportView: View {
    @Environment(\.modelContext) private var context
    @Query private var reports: [Report]
    @State private var selectedDate = Date()
    @State private var pdfData: Data?
    @State private var showShareSheet = false
    @State private var showDatePicker = false
    @State private var selectedPeriod: ReportPeriod = .month
    @State private var selectedDepartment: String = "All Departments"
    @AppStorage("minPerformance") private var minPerformance = 70.0
    @AppStorage("minVolumeOfWork") private var minVolumeOfWork = 70.0
    @AppStorage("minTaskCompletion") private var minTaskCompletion = 70.0
    
    private var departments: [String] {
        ["All Departments"] + Array(Set(reports.map { $0.departmentName })).sorted()
    }
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    private var periodFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            formatter.formattingContext = .standalone
        case .quarter:
            let month = Calendar.current.component(.month, from: selectedDate)
            let quarter = (month - 1) / 3 + 1
            formatter.dateFormat = "'Q'\(quarter) yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }
        return formatter
    }
    
    private var reportTitle: String {
        switch selectedPeriod {
        case .month:
            return "Monthly Report - \(periodFormatter.string(from: selectedDate))"
        case .quarter:
            let month = Calendar.current.component(.month, from: selectedDate)
            let quarter = (month - 1) / 3 + 1
            return "Quarterly Report - Q\(quarter) \(Calendar.current.component(.year, from: selectedDate))"
        case .year:
            return "Yearly Report - \(Calendar.current.component(.year, from: selectedDate))"
        }
    }
    
    private let reportsSummaryTitle = "reports_summary".localized()
    private let departmentPerformanceTitle = "department_performance_overview".localized()
    private let qualityMetricsTitle = "quality_metrics".localized()
    private let performanceTitle = "performance".localized()
    private let volumeOfWorkTitle = "volume_of_work".localized()
    private let taskCompletionTitle = "task_completion".localized()
    private let analyticsChartsTitle = "analytics_charts".localized()
    
    var body: some View {
        List {
            Section {
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text("report_period".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { period in
                            Text(period.localizedName)
                        }
                    }
                    .onChange(of: selectedPeriod) {
                        generateAndSharePDF()
                    }
                }
                
                HStack {
                    HStack {
                        Image(systemName: "building.2")
                        Text("select_department".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $selectedDepartment) {
                        ForEach(departments, id: \.self) { department in
                            Text(department == "All Departments" ? "all_departments".localized() : department)
                                .tag(department)
                        }
                    }
                    .onChange(of: selectedDepartment) {
                        generateAndSharePDF()
                    }
                }
                
                HStack {
                    Image(systemName: selectedPeriod.systemImage)
                        .foregroundStyle(.accent)
                    
                    Button(action: { showDatePicker = true }) {
                        Text(periodFormatter.string(from: selectedDate))
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            if let pdfData = pdfData {
                Section {
                    Button(action: { showShareSheet = true }) {
                        Label("share_pdf".localized(), systemImage: "square.and.arrow.up")
                            .foregroundStyle(.accent)
                    }
                    
                    PDFKitView(data: pdfData)
                        .frame(height: 500)
                }
            }
        }
        .navigationTitle("title_pdf".localized())
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showDatePicker) {
            switch selectedPeriod {
            case .month:
                MonthYearPicker(selectedDate: $selectedDate) {
                    generateAndSharePDF()
                }
            case .quarter:
                QuarterYearPicker(selectedDate: $selectedDate) {
                    generateAndSharePDF()
                }
            case .year:
                YearPicker(selectedDate: $selectedDate) {
                    generateAndSharePDF()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                let fileName = "\(generateReportTitle()).pdf"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                let _ = try? pdfData.write(to: tempURL)
                ShareSheet(items: [tempURL], isPresented: $showShareSheet)
            }
        }
        .onAppear {
            generateAndSharePDF()
        }
    }
    
    private func generateAndSharePDF() {
        let calendar = Calendar.current
        var startDate: Date
        var endDate: Date
        
        switch selectedPeriod {
        case .month:
            startDate = calendar.startOfMonth(for: selectedDate)
            endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) ?? startDate
            
        case .quarter:
            let month = calendar.component(.month, from: selectedDate)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            var components = DateComponents()
            components.year = calendar.component(.year, from: selectedDate)
            components.month = quarterStartMonth
            components.day = 1
            startDate = calendar.date(from: components) ?? selectedDate
            endDate = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: startDate) ?? startDate
            
        case .year:
            var components = DateComponents()
            components.year = calendar.component(.year, from: selectedDate)
            components.month = 1
            components.day = 1
            startDate = calendar.date(from: components) ?? selectedDate
            endDate = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startDate) ?? startDate
        }
        
        var filteredReports = reports.filter { report in
            let isAfterStart = calendar.compare(report.date, to: startDate, toGranularity: .day) != .orderedAscending
            let isBeforeEnd = calendar.compare(report.date, to: endDate, toGranularity: .day) != .orderedDescending
            return isAfterStart && isBeforeEnd
        }
        
        if selectedDepartment != "All Departments" {
            filteredReports = filteredReports.filter { $0.departmentName == selectedDepartment }
        }
        
        let pdfGenerator = PDFGenerator(
            date: selectedDate,
            reports: filteredReports,
            reportTitle: generateReportTitle(),
            period: selectedPeriod,
            minPerformance: minPerformance,
            minVolumeOfWork: minVolumeOfWork,
            minTaskCompletion: minTaskCompletion
        )
        
        self.pdfData = pdfGenerator.generatePDF()
    }
    
    private func generateReportTitle() -> String {
        let periodTitle: String
        switch selectedPeriod {
        case .month:
            periodTitle = "monthly_report".localized()
        case .quarter:
            periodTitle = "quarterly_report".localized()
        case .year:
            periodTitle = "yearly_report".localized()
        }
        
        let departmentTitle = selectedDepartment == "All Departments" ? 
            "all_departments".localized() : selectedDepartment
        
        return "\(periodTitle) - \(departmentTitle) - \(periodFormatter.string(from: selectedDate))"
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - PDF Generator
class PDFGenerator {
    private let date: Date
    private let reports: [Report]
    private let pageWidth: CGFloat = 612
    private let pageHeight: CGFloat = 792
    private let margin: CGFloat = 50
    private let reportTitle: String
    private let period: ReportPeriod
    private let minPerformance: Double
    private let minVolumeOfWork: Double
    private let minTaskCompletion: Double
    
    private let reportsSummaryTitle = "reports_summary".localized()
    private let departmentPerformanceTitle = "department_performance_overview".localized()
    private let qualityMetricsTitle = "quality_metrics".localized()
    private let performanceTitle = "performance".localized()
    private let volumeOfWorkTitle = "volume_of_work".localized()
    private let taskCompletionTitle = "task_completion".localized()
    private let analyticsChartsTitle = "analytics_charts".localized()
    
    private let chartColors: [UIColor] = [.systemBlue, .systemGreen, .systemRed, .systemOrange, .systemPurple]
    
    // Mantener un orden y color fijo para los departamentos
    private static var departmentOrder: [String] = []
    private static var departmentColors: [String: UIColor] = [:]
    private let availableColors: [UIColor] = [
        .systemBlue, .systemGreen, .systemRed,
        .systemOrange, .systemPurple, .systemTeal
    ]
    
    private var departmentData: [String: [Report]] = [:]
    
    init(
        date: Date,
        reports: [Report],
        reportTitle: String,
        period: ReportPeriod,
        minPerformance: Double,
        minVolumeOfWork: Double,
        minTaskCompletion: Double
    ) {
        self.date = date
        self.reports = reports
        self.reportTitle = reportTitle
        self.period = period
        self.minPerformance = minPerformance
        self.minVolumeOfWork = minVolumeOfWork
        self.minTaskCompletion = minTaskCompletion
        
        // Agrupar los informes por departamento
        self.departmentData = Dictionary(grouping: reports) { $0.departmentName }
        
        // Asignar colores fijos la primera vez que vemos un departamento
        let departments = Array(departmentData.keys).sorted()
        departments.forEach { department in
            if !PDFGenerator.departmentOrder.contains(department) {
                PDFGenerator.departmentOrder.append(department)
                PDFGenerator.departmentColors[department] = availableColors[PDFGenerator.departmentColors.count % availableColors.count]
            }
        }
    }
    
    private func averagePerformance() -> Double {
        guard !reports.isEmpty else { return 0 }
        return reports.map(\.performanceMark).average
    }
    
    private func averageVolumeOfWork() -> Double {
        guard !reports.isEmpty else { return 0 }
        return reports.map(\.volumeOfWorkMark).average
    }
    
    private func averageCompletion() -> Double {
        let completed = Double(reports.reduce(0) { $0 + $1.tasksCompletedWithoutDelay })
        let total = Double(reports.reduce(0) { $0 + $1.totalTasksCreated })
        guard total > 0 else { return 0 }
        return (completed / total) * 100
    }
    
    private func calculateTrend(values: [Double]) -> String {
        guard values.count >= 2 else { return "Stable" }
        
        let firstHalf = Array(values.prefix(values.count / 2))
        let secondHalf = Array(values.suffix(values.count / 2))
        
        let firstAvg = firstHalf.reduce(0.0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0.0, +) / Double(secondHalf.count)
        
        if secondAvg > firstAvg * 1.05 {
            return "Improving"
        } else if secondAvg < firstAvg * 0.95 {
            return "Declining"
        }
        return "Stable"
    }
    
    func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Business Manager",
            kCGPDFContextAuthor: "Business Manager App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            drawPDFContent(context: context)
        }
    }
    
    private func drawPDFContent(context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        // Título del reporte
        (reportTitle as NSString).draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
        
        // Reports summary section
        let summaryTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        let summaryTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14)
        ]
        
        let reportsY = margin + 50
        let reportsSummaryTitle = "reports_summary".localized()
        (reportsSummaryTitle as NSString).draw(
            at: CGPoint(x: margin, y: reportsY),
            withAttributes: summaryTitleAttributes
        )
        
        // Draw reports details with all metrics
        let reportDetails = """
        \("reports_total".localized()): \(reports.count)
        \("performance_average".localized()): \(String(format: "%.1f", averagePerformance()))
        \("volume_average".localized()): \(String(format: "%.1f", averageVolumeOfWork()))
        \("tasks_created_total".localized()): \(totalTasksCreated())
        \("tasks_completed_total".localized()): \(totalTasks())
        \("tasks_completed_on_time_total".localized()): \(totalTasksCompletedOnTime())
        """
        
        (reportDetails as NSString).draw(
            at: CGPoint(x: margin, y: reportsY + 20),
            withAttributes: summaryTextAttributes
        )
        
        // Department performance title
        let departmentPerformanceTitle = "department_performance_overview".localized()
        (departmentPerformanceTitle as NSString).draw(
            at: CGPoint(x: pageWidth - margin - 280, y: reportsY),
            withAttributes: summaryTitleAttributes
        )
        
        // Draw logo en la esquina inferior derecha
        if let logo = UIImage(named: "pdf_logo") {
            let logoSize: CGFloat = 80
            let aspectRatio = logo.size.width / logo.size.height
            let logoHeight = logoSize
            let logoWidth = logoHeight * aspectRatio
            
            let logoX = pageWidth - margin - logoWidth
            let logoY = pageHeight - (margin / 4) - logoHeight
            let logoRect = CGRect(x: logoX, y: logoY, width: logoWidth, height: logoHeight)
            logo.draw(in: logoRect)
        }
        
        // Dibujar gráfico de radar (siempre, incluso sin datos)
        let centerX = pageWidth - margin - 150
        let centerY = reportsY + 130
        let radarRadius: CGFloat = 80
        let axes = 3
        let angleStep = 2 * CGFloat.pi / CGFloat(axes)
        
        // Dibujar círculos de referencia
        let referenceCircles = [0.2, 0.4, 0.6, 0.8, 1.0]
        for reference in referenceCircles {
            let path = UIBezierPath()
            for i in 0...axes {
                let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
                let point = CGPoint(
                    x: centerX + cos(angle) * (radarRadius * CGFloat(reference)),
                    y: centerY + sin(angle) * (radarRadius * CGFloat(reference))
                )
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.close()
            UIColor.gray.withAlphaComponent(0.2).setStroke()
            path.lineWidth = 0.5
            path.stroke()
        }
        
        // Dibujar líneas de los ejes
        for i in 0..<axes {
            let path = UIBezierPath()
            let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
            path.move(to: CGPoint(x: centerX, y: centerY))
            path.addLine(to: CGPoint(
                x: centerX + cos(angle) * radarRadius,
                y: centerY + sin(angle) * radarRadius
            ))
            UIColor.gray.setStroke()
            path.lineWidth = 0.5
            path.stroke()
        }
        
        // Dibujar etiquetas de los ejes
        let axisLabels = [
            "radar_performance".localized(),
            "radar_volume".localized(),
            "radar_tasks".localized()
        ]
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        for (i, label) in axisLabels.enumerated() {
            let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
            let point = CGPoint(
                x: centerX + cos(angle) * (radarRadius + 15),
                y: centerY + sin(angle) * (radarRadius + 15)
            )
            (label as NSString).draw(
                at: point,
                withAttributes: labelAttributes
            )
        }
        
        // Solo dibujar datos de departamentos si existen
        if !departmentData.isEmpty {
            // Calcular el máximo número de tareas
            let maxTasks = departmentData.values.flatMap { reports in
                reports.map { $0.numberOfFinishedTasks }
            }.max() ?? 1
            
            // Dibujar datos por departamento
            let sortedDepartments = getSortedDepartments()
            sortedDepartments.forEach { department in
                guard let reports = departmentData[department] else { return }
                
                let avgPerformance = reports.reduce(0.0) { $0 + Double($1.performanceMark) } / Double(reports.count) / 100.0
                let avgVolume = reports.reduce(0.0) { $0 + Double($1.volumeOfWorkMark) } / Double(reports.count) / 100.0
                let avgTasks = Double(reports.reduce(0) { $0 + $1.numberOfFinishedTasks }) / Double(reports.count) / Double(maxTasks)
                
                let values = [avgPerformance, avgVolume, avgTasks]
                let path = UIBezierPath()
                
                for i in 0...axes {
                    let idx = i % axes
                    let angle = CGFloat(idx) * angleStep - CGFloat.pi / 2
                    let value = CGFloat(values[idx])
                    let point = CGPoint(
                        x: centerX + cos(angle) * (radarRadius * value),
                        y: centerY + sin(angle) * (radarRadius * value)
                    )
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                
                path.close()
                let departmentColor = getColorForDepartment(department)
                departmentColor.withAlphaComponent(0.5).setFill()
                departmentColor.setStroke()
                path.lineWidth = 1.0
                path.fill()
                path.stroke()
                
                // Dibujar leyenda
                let legendX = centerX + radarRadius + 30
                let legendY = centerY - radarRadius + (CGFloat(sortedDepartments.firstIndex(of: department) ?? 0) * 20)
                
                departmentColor.setFill()
                let legendRect = CGRect(x: legendX, y: legendY, width: 10, height: 10)
                UIBezierPath(rect: legendRect).fill()
                
                let legendText = department
                let legendAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10)
                ]
                (legendText as NSString).draw(
                    at: CGPoint(x: legendX + 15, y: legendY),
                    withAttributes: legendAttributes
                )
            }
        }
        
        // Draw quality metrics with less spacing from reports
        let metricsY = reportsY + 200
        let qualityMetricsTitle = "quality_metrics".localized()
        (qualityMetricsTitle as NSString).draw(
            at: CGPoint(x: margin, y: metricsY),
            withAttributes: summaryTitleAttributes
        )
        
        let metrics = [
            (performanceTitle, averagePerformance(), minPerformance),
            (volumeOfWorkTitle, averageVolumeOfWork(), minVolumeOfWork),
            (taskCompletionTitle, averageCompletion(), minTaskCompletion)
        ]
        
        let metricWidth: CGFloat = (pageWidth - (2 * margin) - 40) / 3
        
        metrics.enumerated().forEach { index, metric in
            let metricX = margin + (CGFloat(index) * (metricWidth + 20))
            let metricY = metricsY + 40
            
            // Draw metric title
            (metric.0 as NSString).draw(
                at: CGPoint(x: metricX, y: metricY),
                withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 14)
                ]
            )
            
            // Draw metric value with color based on threshold
            let isAboveMinimum = metric.1 >= metric.2
            ("\(Int(metric.1))%" as NSString).draw(
                at: CGPoint(x: metricX, y: metricY + 25),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: isAboveMinimum ? UIColor.systemGreen : UIColor.systemRed
                ]
            )
            
            // Draw progress bar
            let barHeight: CGFloat = 8
            let barWidth = metricWidth - 20
            let barY = metricY + 60
            
            // Background bar
            let backgroundBar = UIBezierPath(
                roundedRect: CGRect(x: metricX, y: barY, width: barWidth, height: barHeight),
                cornerRadius: 4
            )
            UIColor.systemGray5.setFill()
            backgroundBar.fill()
            
            // Progress bar with color based on threshold
            let progressWidth = barWidth * CGFloat(metric.1 / 100)
            let progressBar = UIBezierPath(
                roundedRect: CGRect(x: metricX, y: barY, width: progressWidth, height: barHeight),
                cornerRadius: 4
            )
            (isAboveMinimum ? UIColor.systemGreen : UIColor.systemRed).setFill()
            progressBar.fill()
        }
        
        // Charts section
        let chartsY = metricsY + 350
        
        // Título de la sección de Analytics
        let analyticsChartsTitle = "analytics_charts".localized()
        (analyticsChartsTitle as NSString).draw(
            at: CGPoint(x: margin, y: chartsY - 200),
            withAttributes: summaryTitleAttributes
        )
        
        // Ajustado para solo 2 charts con más espacio
        let chartWidth = (pageWidth - (2 * margin) - 20) / 2
        let chartHeight: CGFloat = 150
        let chartY = chartsY + 20
        
        // Draw only two charts side by side and centered
        let firstChartX = margin + (pageWidth - (2 * margin) - (2 * chartWidth)) / 3
        
        // Primer chart con título (ajustado a 180 puntos)
        let performanceTitle = "performance_chart".localized()
        (performanceTitle as NSString).draw(
            at: CGPoint(x: firstChartX + (chartWidth / 2) - 40, y: chartY - 180),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        
        drawProductivityChart(
            at: CGPoint(x: firstChartX, y: chartY),
            size: CGSize(width: chartWidth, height: chartHeight)
        )
        
        // Segundo chart con título (ajustado a 180 puntos)
        let volumeTitle = "volume_chart".localized()
        (volumeTitle as NSString).draw(
            at: CGPoint(x: firstChartX + chartWidth + (chartWidth / 2) - 30, y: chartY - 180),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        
        drawVolumeChart(
            at: CGPoint(x: firstChartX + chartWidth + 20, y: chartY),
            size: CGSize(width: chartWidth, height: chartHeight)
        )
    }
    
    private func drawProductivityChart(at point: CGPoint, size: CGSize) {
        // Draw chart content first
        let path = UIBezierPath()
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x + size.width, y: point.y))
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x, y: point.y - size.height))
        UIColor.gray.setStroke()
        path.stroke()
        
        departmentData.forEach { department, reports in
            let sortedReports = reports.sorted { $0.date < $1.date }
            let path = UIBezierPath()
            let step = size.width / CGFloat(max(sortedReports.count - 1, 1))
            
            for (i, report) in sortedReports.enumerated() {
                let x = point.x + (CGFloat(i) * step)
                let y = point.y - (CGFloat(report.performanceMark) / 100.0 * size.height)
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            getColorForDepartment(department).setStroke()
            path.lineWidth = 1.5
            path.stroke()
        }
    }
    
    private func drawVolumeChart(at point: CGPoint, size: CGSize) {
        // Draw chart content first
        let path = UIBezierPath()
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x + size.width, y: point.y))
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x, y: point.y - size.height))
        UIColor.gray.setStroke()
        path.stroke()
        
        departmentData.forEach { department, reports in
            let color = getColorForDepartment(department)
            
            reports.forEach { report in
                let x = point.x + (CGFloat(report.volumeOfWorkMark) / 100.0 * size.width)
                let y = point.y - (CGFloat(report.performanceMark) / 100.0 * size.height)
                
                let dotPath = UIBezierPath(ovalIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
                color.setFill()
                dotPath.fill()
            }
        }
    }
    
    private func totalTasks() -> Int {
        reports.reduce(into: 0) { result, report in
            result += report.numberOfFinishedTasks
        }
    }
    
    private func totalTasksCreated() -> Int {
        reports.reduce(into: 0) { result, report in
            result += report.totalTasksCreated
        }
    }
    
    private func totalTasksCompletedOnTime() -> Int {
        reports.reduce(into: 0) { result, report in
            result += report.tasksCompletedWithoutDelay
        }
    }
    
    private let summaryTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12)
    ]
    
    private func drawReportsSummary(at point: CGPoint) {
        // Dibujar el título de la sección
        ("reports_summary".localized() as NSString).draw(
            at: CGPoint(x: margin, y: point.y),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
        )
        
        // Preparar el texto del resumen con todas las métricas
        let summaryText = """
        \("reports_total".localized()): \(reports.count)
        \("performance_average".localized()): \(String(format: "%.1f%%", averagePerformance()))
        \("volume_average".localized()): \(String(format: "%.1f%%", averageVolumeOfWork()))
        \("tasks_created_total".localized()): \(totalTasksCreated())
        \("tasks_completed_total".localized()): \(totalTasks())
        \("tasks_completed_on_time_total".localized()): \(totalTasksCompletedOnTime())
        """
        
        // Dibujar el contenido del resumen
        (summaryText as NSString).draw(
            at: CGPoint(x: margin + 20, y: point.y + 30),
            withAttributes: summaryTextAttributes
        )
    }
    
    private func drawDepartmentPerformance(at point: CGPoint) {
        // Dibujar el título de la sección
        ("department_performance_overview".localized() as NSString).draw(
            at: CGPoint(x: margin, y: point.y),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
        )
    }
    
    private func drawQualityMetrics(at point: CGPoint) {
        // Dibujar el título de la sección
        ("quality_metrics".localized() as NSString).draw(
            at: CGPoint(x: margin, y: point.y),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
        )
    }
    
    private func drawAnalyticsCharts(at point: CGPoint) {
        // Dibujar el título de la sección
        ("analytics_charts".localized() as NSString).draw(
            at: CGPoint(x: margin, y: point.y),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
        )
    }
    
    private func getColorForDepartment(_ department: String) -> UIColor {
        return PDFGenerator.departmentColors[department] ?? .systemGray
    }
    
    private func getSortedDepartments() -> [String] {
        // Usar el orden original guardado
        return PDFGenerator.departmentOrder.filter { departmentData.keys.contains($0) }
    }
}

// MARK: - PDF View
struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(data: data)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    @Binding var isPresented: Bool
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                hapticFeedback.notificationOccurred(.success)
                isPresented = false
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
