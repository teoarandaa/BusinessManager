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
                ShareSheet(items: [pdfData])
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
                let logoSize: CGFloat = 60
                let logoX = pageWidth - margin - logoSize
                let logoY = margin - 15
                let logoRect = CGRect(x: logoX, y: logoY, width: logoSize, height: logoSize)
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
            
            ("Reports Summary" as NSString).draw(at: CGPoint(x: margin, y: margin + 50), withAttributes: summaryTitleAttributes)
            
            let reportDetails = """
            Total Reports: \(reports.count)
            Average Performance: \(String(format: "%.1f", averagePerformance()))
            Average Volume of Work: \(String(format: "%.1f", averageVolumeOfWork()))
            Total Tasks Completed: \(totalTasks())
            """
            
            (reportDetails as NSString).draw(at: CGPoint(x: margin, y: margin + 70), withAttributes: summaryTextAttributes)
            
            // Draw goals summary
            ("Goals Summary" as NSString).draw(at: CGPoint(x: margin, y: margin + 150), withAttributes: summaryTitleAttributes)
            
            let goalDetails = """
            Active Goals: \(goals.filter { $0.status == .inProgress }.count)
            Completed Goals: \(goals.filter { $0.status == .completed }.count)
            Failed Goals: \(goals.filter { $0.status == .failed }.count)
            """
            
            (goalDetails as NSString).draw(at: CGPoint(x: margin, y: margin + 170), withAttributes: summaryTextAttributes)
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
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
