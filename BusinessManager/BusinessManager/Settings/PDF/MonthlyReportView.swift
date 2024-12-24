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
    
    var body: some View {
        List {
            Section {
                Picker("report_period".localized(), selection: $selectedPeriod) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        Text(period.localizedName)
                    }
                }
                .onChange(of: selectedPeriod) {
                    generateAndSharePDF()
                }
                
                Picker("select_department".localized(), selection: $selectedDepartment) {
                    ForEach(departments, id: \.self) { department in
                        Text(department == "All Departments" ? "all_departments".localized() : department)
                            .tag(department)
                    }
                }
                .onChange(of: selectedDepartment) {
                    generateAndSharePDF()
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
        .navigationTitle("monthly_report".localized())
        .navigationBarTitleDisplayMode(.inline)
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
                ShareSheet(items: [pdfData], isPresented: $showShareSheet)
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
    
    private let chartColors: [UIColor] = [.systemBlue, .systemGreen, .systemRed, .systemOrange, .systemPurple]
    
    private var departmentData: [String: [Report]] {
        Dictionary(grouping: reports) { $0.departmentName }
    }
    
    private lazy var departmentColorMap: [String: UIColor] = {
        var colorMap: [String: UIColor] = [:]
        let departments = Array(departmentData.keys).sorted()
        
        for (index, department) in departments.enumerated() {
            colorMap[department] = chartColors[index % chartColors.count]
        }
        return colorMap
    }()
    
    private func getColorForDepartment(_ department: String) -> UIColor {
        return departmentColorMap[department] ?? chartColors[0]
    }
    
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
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            
            // Usar el título generado dinámicamente
            (reportTitle as NSString).draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
            
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
            
            // Draw reports summary
            let summaryTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]
            let summaryTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14)
            ]
            
            let reportsY = margin + 50
            ("reports_summary".localized() as NSString).draw(at: CGPoint(x: margin, y: reportsY), withAttributes: summaryTitleAttributes)
            
            ("department_performance_overview".localized() as NSString).draw(
                at: CGPoint(x: pageWidth - margin - 280, y: reportsY),
                withAttributes: summaryTitleAttributes
            )
            
            // Draw reports details
            let reportDetails = """
            \("total_reports".localized()): \(reports.count)
            \("average_performance".localized()): \(String(format: "%.1f", averagePerformance()))
            \("average_volume".localized()): \(String(format: "%.1f", averageVolumeOfWork()))
            \("total_tasks_completed".localized()): \(totalTasks())
            """
            
            (reportDetails as NSString).draw(at: CGPoint(x: margin, y: reportsY + 20), withAttributes: summaryTextAttributes)
            
            // Draw radar chart
            let radarCenterY = reportsY + 130
            let centerX = pageWidth - margin - 150
            let radarRadius: CGFloat = 80
            let departmentReports = Dictionary(grouping: reports, by: { $0.departmentName })
            
            // Dibujar ejes del radar (siempre)
            let axes = 3
            let angleStep = 2 * CGFloat.pi / CGFloat(axes)
            
            // Dibujar círculos de referencia (20%, 40%, 60%, 80%, 100%)
            let referenceCircles = [0.2, 0.4, 0.6, 0.8, 1.0]
            for reference in referenceCircles {
                let path = UIBezierPath()
                for i in 0...axes {
                    let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
                    let point = CGPoint(
                        x: centerX + cos(angle) * (radarRadius * CGFloat(reference)),
                        y: radarCenterY + sin(angle) * (radarRadius * CGFloat(reference))
                    )
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.close()
                UIColor.gray.withAlphaComponent(0.2).setStroke()
                path.stroke()
            }
            
            // Dibujar líneas de los ejes
            for i in 0..<axes {
                let path = UIBezierPath()
                let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
                path.move(to: CGPoint(x: centerX, y: radarCenterY))
                path.addLine(to: CGPoint(
                    x: centerX + cos(angle) * radarRadius,
                    y: radarCenterY + sin(angle) * radarRadius
                ))
                UIColor.gray.setStroke()
                path.stroke()
            }
            
            // Dibujar etiquetas de los ejes
            let axisLabels = ["Performance", "Volume", "Tasks"]
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10)
            ]
            
            for (i, label) in axisLabels.enumerated() {
                let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
                let point = CGPoint(
                    x: centerX + cos(angle) * (radarRadius + 15),
                    y: radarCenterY + sin(angle) * (radarRadius + 15)
                )
                (label as NSString).draw(
                    at: point,
                    withAttributes: labelAttributes
                )
            }
            
            // Solo dibujamos los datos si existen
            if !departmentReports.isEmpty {
                // Dibujar datos por departamento
                let colors: [UIColor] = [.systemBlue, .systemGreen, .systemRed,
                                       .systemOrange, .systemPurple, .systemTeal]
                
                // Encontrar el máximo número de tareas entre todos los departamentos
                let maxTasks = departmentReports.values.flatMap { reports in
                    reports.map { $0.numberOfFinishedTasks }
                }.max() ?? 1
                
                departmentReports.enumerated().forEach { index, entry in
                    let reports = entry.value
                    let avgPerformance = reports.reduce(0.0) { $0 + Double($1.performanceMark) } / Double(reports.count) / 100.0
                    let avgVolume = reports.reduce(0.0) { $0 + Double($1.volumeOfWorkMark) } / Double(reports.count) / 100.0
                    
                    // Normalizar tareas usando el máximo real
                    let avgTasks = Double(reports.reduce(0) { $0 + $1.numberOfFinishedTasks }) / Double(reports.count) / Double(maxTasks)
                    
                    let values = [avgPerformance, avgVolume, avgTasks]
                    let path = UIBezierPath()
                    
                    for i in 0...axes {
                        let idx = i % axes
                        let angle = CGFloat(idx) * angleStep - CGFloat.pi / 2
                        let value = CGFloat(values[idx])
                        let point = CGPoint(
                            x: centerX + cos(angle) * (radarRadius * value),
                            y: radarCenterY + sin(angle) * (radarRadius * value)
                        )
                        
                        if i == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    
                    path.close()
                    colors[index % colors.count].withAlphaComponent(0.5).setFill()
                    colors[index % colors.count].setStroke()
                    path.fill()
                    path.stroke()
                    
                    // Dibujar leyenda
                    let legendX = centerX + radarRadius + 30
                    let legendY = radarCenterY - radarRadius + (CGFloat(index) * 20)
                    
                    colors[index % colors.count].setFill()
                    let legendRect = CGRect(x: legendX, y: legendY, width: 10, height: 10)
                    UIBezierPath(rect: legendRect).fill()
                    
                    let legendText = entry.key
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
            ("Quality Metrics" as NSString).draw(
                at: CGPoint(x: margin, y: metricsY),
                withAttributes: summaryTitleAttributes
            )
            
            let metrics = [
                ("Performance", averagePerformance(), minPerformance),
                ("Volume of Work", averageVolumeOfWork(), minVolumeOfWork),
                ("Task Completion", averageCompletion(), minTaskCompletion)
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
            
            // Charts section with title much higher up
            let chartsY = metricsY + 350
            
            ("Analytics Charts" as NSString).draw(
                at: CGPoint(x: margin, y: chartsY - 180),
                withAttributes: summaryTitleAttributes
            )
            
            let chartWidth = (pageWidth - (2 * margin) - 40) / 3
            let chartHeight: CGFloat = 150
            
            // Draw all three charts side by side
            drawProductivityChart(
                at: CGPoint(x: margin, y: chartsY),
                size: CGSize(width: chartWidth, height: chartHeight),
                title: "Productivity Trends"
            )
            
            drawEfficiencyChart(
                at: CGPoint(x: margin + chartWidth + 20, y: chartsY),
                size: CGSize(width: chartWidth, height: chartHeight),
                title: "Efficiency Analysis"
            )
            
            drawPerformanceChart(
                at: CGPoint(x: margin + (chartWidth + 20) * 2, y: chartsY),
                size: CGSize(width: chartWidth, height: chartHeight),
                title: "Performance Overview"
            )
        }
        
        return data
    }
    
    private func drawProductivityChart(at point: CGPoint, size: CGSize, title: String) {
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
        
        // Draw legend
        let sortedDepartments = Array(departmentData.keys).sorted()
        sortedDepartments.enumerated().forEach { index, department in
            let legendX = point.x + (CGFloat(index) * 80)
            let legendY = point.y + 35
            
            let legendRect = CGRect(x: legendX, y: legendY, width: 8, height: 8)
            getColorForDepartment(department).setFill()
            UIBezierPath(rect: legendRect).fill()
            
            (department as NSString).draw(
                at: CGPoint(x: legendX + 12, y: legendY),
                withAttributes: [.font: UIFont.systemFont(ofSize: 8)]
            )
        }
    }
    
    private func drawEfficiencyChart(at point: CGPoint, size: CGSize, title: String) {
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
        
        // Draw legend
        let sortedDepartments = Array(departmentData.keys).sorted()
        sortedDepartments.enumerated().forEach { index, department in
            let legendX = point.x + (CGFloat(index) * 80)
            let legendY = point.y + 35
            
            let legendRect = CGRect(x: legendX, y: legendY, width: 8, height: 8)
            getColorForDepartment(department).setFill()
            UIBezierPath(rect: legendRect).fill()
            
            (department as NSString).draw(
                at: CGPoint(x: legendX + 12, y: legendY),
                withAttributes: [.font: UIFont.systemFont(ofSize: 8)]
            )
        }
    }
    
    private func drawPerformanceChart(at point: CGPoint, size: CGSize, title: String) {
        // Draw chart content first
        let path = UIBezierPath()
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x + size.width, y: point.y))
        path.move(to: point)
        path.addLine(to: CGPoint(x: point.x, y: point.y - size.height))
        UIColor.gray.setStroke()
        path.stroke()
        
        let barSpacing: CGFloat = 5
        let sortedDepartments = Array(departmentData.keys).sorted()
        let barWidth = (size.width - (barSpacing * CGFloat(departmentData.count - 1))) / CGFloat(departmentData.count)
        
        sortedDepartments.enumerated().forEach { index, department in
            let reports = departmentData[department] ?? []
            let avgPerformance = reports.map(\.performanceMark).average
            let x = point.x + (CGFloat(index) * (barWidth + barSpacing))
            let height = CGFloat(avgPerformance) / 100.0 * size.height
            
            let barRect = CGRect(x: x, y: point.y - height, width: barWidth, height: height)
            getColorForDepartment(department).setFill()
            UIBezierPath(rect: barRect).fill()
            
            // Legend
            let legendX = point.x + (CGFloat(index) * 80)
            let legendY = point.y + 35
            
            let legendRect = CGRect(x: legendX, y: legendY, width: 8, height: 8)
            getColorForDepartment(department).setFill()
            UIBezierPath(rect: legendRect).fill()
            
            (department as NSString).draw(
                at: CGPoint(x: legendX + 12, y: legendY),
                withAttributes: [.font: UIFont.systemFont(ofSize: 8)]
            )
            
            // Performance value
            ("\(Int(avgPerformance))%" as NSString).draw(
                at: CGPoint(x: x, y: point.y - height - 10),
                withAttributes: [.font: UIFont.systemFont(ofSize: 8)]
            )
        }
    }
    
    private func totalTasks() -> Int {
        reports.reduce(into: 0) { result, report in
            result += report.numberOfFinishedTasks
        }
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
