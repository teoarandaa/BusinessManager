import SwiftUI
import PDFKit
import SwiftData
import Charts

// MARK: - Report Period Enum
enum ReportPeriod: String, CaseIterable {
    case month = "Monthly"
    case quarter = "Quarterly"
    case year = "Yearly"
    
    var systemImage: String {
        switch self {
        case .month: return "calendar"
        case .quarter: return "calendar.badge.clock"
        case .year: return "calendar.badge.exclamationmark"
        }
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
                        Text(months[index]).tag(index)
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
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
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
    private let quarters = ["Q1 (Jan-Mar)", "Q2 (Apr-Jun)", "Q3 (Jul-Sep)", "Q4 (Oct-Dec)"]
    
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
            .navigationTitle("Select Quarter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
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
            .navigationTitle("Select Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
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
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    private var periodFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
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
                Picker("Report Period", selection: $selectedPeriod) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue)
                    }
                }
                .onChange(of: selectedPeriod) {
                    generatePDFReport()
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
                        Label("Share PDF Report", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.accent)
                    }
                    
                    PDFKitView(data: pdfData)
                        .frame(height: 500)
                }
            }
        }
        .navigationTitle(reportTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDatePicker) {
            switch selectedPeriod {
            case .month:
                MonthYearPicker(selectedDate: $selectedDate) {
                    generatePDFReport()
                }
            case .quarter:
                QuarterYearPicker(selectedDate: $selectedDate) {
                    generatePDFReport()
                }
            case .year:
                YearPicker(selectedDate: $selectedDate) {
                    generatePDFReport()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData], isPresented: $showShareSheet)
            }
        }
        .onAppear {
            generatePDFReport()
        }
    }
    
    private func generatePDFReport() {
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
        
        let filteredReports = reports.filter { report in
            let isAfterStart = calendar.compare(report.date, to: startDate, toGranularity: .day) != .orderedAscending
            let isBeforeEnd = calendar.compare(report.date, to: endDate, toGranularity: .day) != .orderedDescending
            return isAfterStart && isBeforeEnd
        }
        
        let pdfGenerator = PDFGenerator(
            date: selectedDate,
            reports: filteredReports,
            reportTitle: reportTitle,
            period: selectedPeriod
        )
        self.pdfData = pdfGenerator.generatePDF()
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
    
    init(date: Date, reports: [Report], reportTitle: String, period: ReportPeriod) {
        self.date = date
        self.reports = reports
        self.reportTitle = reportTitle
        self.period = period
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
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            
            // Usar el título generado dinámicamente
            (reportTitle as NSString).draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
            
            // Draw logo
            if let logo = UIImage(named: "pdf_logo") {
                let logoSize: CGFloat = 80
                let aspectRatio = logo.size.width / logo.size.height
                let logoHeight = logoSize
                let logoWidth = logoHeight * aspectRatio
                
                let logoX = pageWidth - margin - logoWidth
                let logoY = margin - 25
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
            ("Reports Summary" as NSString).draw(at: CGPoint(x: margin, y: reportsY), withAttributes: summaryTitleAttributes)
            
            ("Department Performance Overview" as NSString).draw(
                at: CGPoint(x: pageWidth - margin - 280, y: reportsY),
                withAttributes: summaryTitleAttributes
            )
            
            // Draw reports details
            let reportDetails = """
            Total Reports: \(reports.count)
            Average Performance: \(String(format: "%.1f", averagePerformance()))
            Average Volume of Work: \(String(format: "%.1f", averageVolumeOfWork()))
            Total Tasks Completed: \(totalTasks())
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
            
            // Draw quality metrics
            let metricsY = reportsY + 200
            ("Quality Metrics" as NSString).draw(
                at: CGPoint(x: margin, y: metricsY),
                withAttributes: summaryTitleAttributes
            )
            
            let metrics = [
                ("Performance", averagePerformance()),
                ("Volume of Work", averageVolumeOfWork()),
                ("Task Completion", averageCompletion())
            ]
            
            let metricWidth: CGFloat = (pageWidth - (2 * margin) - 40) / 3
            
            for (index, metric) in metrics.enumerated() {
                let metricX = margin + (metricWidth + 20) * CGFloat(index)
                let metricY = metricsY + 30
                
                // Dibujar título de la métrica
                (metric.0 as NSString).draw(
                    at: CGPoint(x: metricX, y: metricY),
                    withAttributes: summaryTextAttributes
                )
                
                // Dibujar valor
                ("\(String(format: "%.1f", metric.1))%" as NSString).draw(
                    at: CGPoint(x: metricX, y: metricY + 25),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                        .foregroundColor: metric.1 >= 70 ? UIColor.systemGreen : UIColor.systemRed
                    ]
                )
                
                // Dibujar gráfico de barras simple
                let barHeight: CGFloat = 8
                let barWidth = metricWidth - 20
                let barY = metricY + 60
                
                // Barra de fondo
                let backgroundBar = UIBezierPath(
                    roundedRect: CGRect(x: metricX, y: barY, width: barWidth, height: barHeight),
                    cornerRadius: 4
                )
                UIColor.systemGray5.setFill()
                backgroundBar.fill()
                
                // Barra de progreso
                let progressWidth = barWidth * CGFloat(metric.1 / 100)
                let progressBar = UIBezierPath(
                    roundedRect: CGRect(x: metricX, y: barY, width: progressWidth, height: barHeight),
                    cornerRadius: 4
                )
                (metric.1 >= 70 ? UIColor.systemGreen : UIColor.systemRed).setFill()
                progressBar.fill()
            }
        }
        
        return data
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
