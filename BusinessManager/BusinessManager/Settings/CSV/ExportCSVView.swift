import SwiftUI
import SwiftData

enum ExportPeriod: String, CaseIterable {
    case month = "monthly"
    case quarter = "quarterly"
    case year = "yearly"
    
    var localizedName: String {
        rawValue.localized()
    }
    
    var systemImage: String {
        switch self {
        case .month: return "calendar"
        case .quarter: return "calendar.badge.clock"
        case .year: return "calendar.badge.exclamationmark"
        }
    }
}

struct ExportCSVView: View {
    @Environment(\.modelContext) private var context
    @Query private var reports: [Report]
    
    @State private var selectedPeriod: ExportPeriod = .month
    @State private var selectedDepartment = "all_departments".localized()
    @State private var selectedDate = Date()
    @State private var departments: [String] = []
    @State private var showShareSheet = false
    @State private var showDatePicker = false
    @State private var csvURL: URL?
    
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
    
    var body: some View {
        List {
            Section {
                // Period Picker
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text("report_period".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $selectedPeriod) {
                        ForEach(ExportPeriod.allCases, id: \.self) { period in
                            Text(period.localizedName)
                        }
                    }
                }
                
                // Department Picker
                HStack {
                    HStack {
                        Image(systemName: "building.2")
                        Text("select_department".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $selectedDepartment) {
                        Text("all_departments".localized())
                            .tag("all_departments".localized())
                        ForEach(departments, id: \.self) { department in
                            Text(department)
                        }
                    }
                }
                
                // Date Selection Button
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: selectedPeriod.systemImage)
                            .foregroundStyle(.accent)
                        Text(periodFormatter.string(from: selectedDate))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(action: prepareAndShowShareSheet) {
                    Label("export_csv".localized(), systemImage: "arrow.down.doc")
                        .foregroundStyle(.accent)
                }
            }
        }
        .navigationTitle("export_csv".localized())
        .onAppear {
            loadDepartments()
        }
        .sheet(isPresented: $showDatePicker) {
            switch selectedPeriod {
            case .month:
                MonthYearPicker(selectedDate: $selectedDate) {
                    showDatePicker = false
                }
            case .quarter:
                QuarterYearPicker(selectedDate: $selectedDate) {
                    showDatePicker = false
                }
            case .year:
                YearPicker(selectedDate: $selectedDate) {
                    showDatePicker = false
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let csvURL = csvURL {
                CSVShareSheet(activityItems: [csvURL], isPresented: $showShareSheet)
            }
        }
    }
    
    private func loadDepartments() {
        departments = Array(Set(reports.map { $0.departmentName })).sorted()
    }
    
    private func prepareAndShowShareSheet() {
        let fileName = "business_manager_report.csv"
        let header = "Department,Date,Tasks Created,Completed On Time,Total Completed,Performance %,Volume %\n"
        
        let filteredReports = reports.filter { isReportIncluded($0) }
        
        var csvString = header
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for report in filteredReports {
            let row = [
                report.departmentName,
                dateFormatter.string(from: report.date),
                String(report.totalTasksCreated),
                String(report.tasksCompletedWithoutDelay),
                String(report.numberOfFinishedTasks),
                String(Int(report.performanceMark)),
                String(Int(report.volumeOfWorkMark))
            ].joined(separator: ",")
            
            csvString += row + "\n"
        }
        
        guard let data = csvString.data(using: .utf8) else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)
        
        csvURL = tempURL
        showShareSheet = true
    }
    
    private func isReportIncluded(_ report: Report) -> Bool {
        // Verificar departamento
        let isInSelectedDepartment = selectedDepartment == "all_departments".localized() || 
                                    report.departmentName == selectedDepartment
        
        // Verificar período
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
        
        let isInSelectedPeriod = report.date >= startDate && report.date <= endDate
        return isInSelectedDepartment && isInSelectedPeriod
    }
}

// Rename ShareSheet to CSVShareSheet
struct CSVShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    @Binding var isPresented: Bool
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
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

#Preview {
    ExportCSVView()
} 