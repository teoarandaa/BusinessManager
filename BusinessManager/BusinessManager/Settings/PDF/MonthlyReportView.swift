import SwiftUI
import PDFKit
import SwiftData
import Charts

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

struct MonthlyReportView: View {
    @Environment(\.modelContext) private var context
    @Query private var reports: [Report]
    @Query private var goals: [Goal]
    @State private var selectedDate = Date()
    @State private var pdfData: Data?
    @State private var showShareSheet = false
    @State private var showDatePicker = false
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    private var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.accent)
                    
                    Button(action: { showDatePicker = true }) {
                        Text(monthFormatter.string(from: selectedDate))
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
        .navigationTitle("Monthly Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDatePicker) {
            MonthYearPicker(selectedDate: $selectedDate) {
                generatePDFReport()
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
        let pdfGenerator = PDFGenerator(date: selectedDate, reports: reportsForSelectedMonth(), goals: goalsForSelectedMonth())
        self.pdfData = pdfGenerator.generatePDF()
    }
    
    private func reportsForSelectedMonth() -> [Report] {
        let calendar = Calendar.current
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? startOfMonth
        
        return reports.filter { report in
            let isAfterStart = calendar.compare(report.date, to: startOfMonth, toGranularity: .day) != .orderedAscending
            let isBeforeEnd = calendar.compare(report.date, to: endOfMonth, toGranularity: .day) != .orderedDescending
            return isAfterStart && isBeforeEnd
        }
    }
    
    private func goalsForSelectedMonth() -> [Goal] {
        let calendar = Calendar.current
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? startOfMonth
        
        return goals.filter { goal in
            let isAfterStart = calendar.compare(goal.deadline, to: startOfMonth, toGranularity: .day) != .orderedAscending
            let isBeforeEnd = calendar.compare(goal.deadline, to: endOfMonth, toGranularity: .day) != .orderedDescending
            return isAfterStart && isBeforeEnd
        }
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
    private let goals: [Goal]
    private let pageWidth: CGFloat = 612
    private let pageHeight: CGFloat = 792
    private let margin: CGFloat = 50
    
    init(date: Date, reports: [Report], goals: [Goal]) {
        self.date = date
        self.reports = reports
        self.goals = goals
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
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let title = "Monthly Report - \(dateFormatter.string(from: date))"
            
            // Draw title
            (title as NSString).draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
            
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
            
            // Goals section
            let goalsY = reportsY + 250
            ("Goals Summary" as NSString).draw(at: CGPoint(x: margin, y: goalsY), withAttributes: summaryTitleAttributes)
            
            ("Completed Goals by Department" as NSString).draw(
                at: CGPoint(x: pageWidth - margin - 280, y: goalsY),
                withAttributes: summaryTitleAttributes
            )
            
            // Draw goals details
            let goalDetails = """
            Active Goals: \(goals.filter { $0.status == .inProgress }.count)
            Completed Goals: \(goals.filter { $0.status == .completed }.count)
            Failed Goals: \(goals.filter { $0.status == .failed }.count)
            """
            
            (goalDetails as NSString).draw(at: CGPoint(x: margin, y: goalsY + 20), withAttributes: summaryTextAttributes)
            
            // Draw pie chart (siempre)
            let pieCenterY = goalsY + 95
            let chartCenterX = pageWidth - margin - 150
            let radius: CGFloat = 60
            
            // Dibujar círculo vacío si no hay datos
            if goals.filter({ $0.status == .completed }).isEmpty {
                let path = UIBezierPath(arcCenter: CGPoint(x: chartCenterX, y: pieCenterY),
                                       radius: radius,
                                       startAngle: 0,
                                       endAngle: 2 * .pi,
                                       clockwise: true)
                UIColor.gray.withAlphaComponent(0.2).setStroke()
                path.stroke()
            } else {
                let departmentGoals = Dictionary(grouping: goals.filter { $0.status == .completed }, by: { $0.department })
                let total = CGFloat(goals.filter { $0.status == .completed }.count)
                
                if total > 0 {
                    var startAngle: CGFloat = 0
                    
                    // Colores para el gráfico
                    let colors: [UIColor] = [.systemBlue, .systemGreen, .systemRed, 
                                           .systemOrange, .systemPurple, .systemTeal]
                    
                    // Dibujar el gráfico circular
                    departmentGoals.enumerated().forEach { index, entry in
                        let percentage = CGFloat(entry.value.count) / total
                        let endAngle = startAngle + (percentage * 2 * .pi)
                        
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: chartCenterX, y: pieCenterY))
                        path.addArc(withCenter: CGPoint(x: chartCenterX, y: pieCenterY),
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true)
                        path.close()
                        
                        colors[index % colors.count].setFill()
                        path.fill()
                        
                        // Dibujar leyenda
                        let legendX = chartCenterX + radius + 30
                        let legendY = pieCenterY - radius + (CGFloat(index) * 20)
                        
                        colors[index % colors.count].setFill()
                        let legendRect = CGRect(x: legendX, y: legendY, width: 10, height: 10)
                        UIBezierPath(rect: legendRect).fill()
                        
                        let legendText = "\(entry.key): \(entry.value.count)"
                        let legendAttributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 10)
                        ]
                        (legendText as NSString).draw(
                            at: CGPoint(x: legendX + 15, y: legendY),
                            withAttributes: legendAttributes
                        )
                        
                        startAngle = endAngle
                    }
                }
            }
        }
        
        return data
    }
    
    private func averagePerformance() -> Double {
        guard !reports.isEmpty else { return 0 }
        let total = reports.reduce(into: 0.0) { result, report in
            result += Double(report.performanceMark)
        }
        return total / Double(reports.count)
    }
    
    private func averageVolumeOfWork() -> Double {
        guard !reports.isEmpty else { return 0 }
        let total = reports.reduce(into: 0.0) { result, report in
            result += Double(report.volumeOfWorkMark)
        }
        return total / Double(reports.count)
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
