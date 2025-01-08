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

struct CSVPreviewView: View {
    let csvString: String
    
    private var rows: [[String]] {
        csvString.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.components(separatedBy: ",") }
    }
    
    // Definir anchos fijos para cada columna
    private let columnWidths: [CGFloat] = [
        120,  // Department
        100,  // Date
        130,   // Tasks Created
        240,  // Tasks Completed On Time
        160,  // Total Tasks Completed
        120,  // Performance %
        150   // Volume %
    ]
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if rows.isEmpty {
                Text("no_data".localized())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    if let headerRow = rows.first {
                        HStack(spacing: 0) {
                            ForEach(headerRow.indices, id: \.self) { index in
                                Text(headerRow[index])
                                    .font(.caption.bold())
                                    .padding(8)
                                    .frame(width: columnWidths[index], alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                            }
                        }
                    }
                    
                    // Data rows
                    if rows.count > 1 {
                        ForEach(Array(rows.dropFirst().enumerated()), id: \.offset) { index, row in
                            HStack(spacing: 0) {
                                ForEach(row.indices, id: \.self) { columnIndex in
                                    Text(row[columnIndex])
                                        .font(.caption)
                                        .padding(8)
                                        .frame(width: columnWidths[columnIndex], alignment: .leading)
                                }
                            }
                            .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
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
    @State private var csvString: String = ""
    
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
                .onChange(of: selectedPeriod) { oldValue, newValue in 
                    generateCSV() 
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
                .onChange(of: selectedDepartment) { oldValue, newValue in 
                    generateCSV() 
                }
                
                // Date Selection Button
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: selectedPeriod.systemImage)
                            .foregroundStyle(.accent)
                        Text(periodFormatter.string(from: selectedDate))
                            .foregroundStyle(.accent)
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(action: prepareAndShowShareSheet) {
                    Label("export_csv".localized(), systemImage: "arrow.down.doc")
                        .foregroundStyle(.accent)
                }
                
                if !csvString.isEmpty {
                    CSVPreviewView(csvString: csvString)
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .navigationTitle("export_csv".localized())
        .onAppear {
            loadDepartments()
            generateCSV()
        }
        .onChange(of: selectedDate) { oldValue, newValue in 
            generateCSV() 
        }
        .sheet(isPresented: $showDatePicker) {
            switch selectedPeriod {
            case .month:
                ExportMonthYearPicker(selectedDate: $selectedDate) {
                    generateCSV()
                    showDatePicker = false
                }
            case .quarter:
                QuarterYearPicker(selectedDate: $selectedDate) {
                    generateCSV()
                    showDatePicker = false
                }
            case .year:
                YearPicker(selectedDate: $selectedDate) {
                    generateCSV()
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
    
    private func generateCSV() {
        // Headers
        csvString = "\("department".localized()),"
        csvString += "\("date".localized()),"
        csvString += "\("tasks_created".localized()),"
        csvString += "\("tasks_completed_ontime".localized()),"
        csvString += "\("total_completed".localized()),"
        csvString += "\("performance".localized()),"
        csvString += "\("volume_of_work".localized())\n"
        
        let filteredReports = reports.filter { isReportIncluded($0) }
        
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
    }
    
    private func prepareAndShowShareSheet() {
        guard let data = csvString.data(using: .utf8) else { return }
        
        let fileName = "business_manager_report.csv"
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

// Rename just this struct
struct ExportMonthYearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    let onDateSelected: () -> Void
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let years = Array((2020...Calendar.current.component(.year, from: Date())).reversed())
    private let months = Calendar.current.monthSymbols
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping () -> Void) {
        self._selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        
        let calendar = Calendar.current
        let date = selectedDate.wrappedValue
        _selectedYear = State(initialValue: calendar.component(.year, from: date))
        _selectedMonth = State(initialValue: calendar.component(.month, from: date) - 1)
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
            .onChange(of: selectedYear) { oldValue, newValue in 
                updateSelectedDate() 
            }
            .onChange(of: selectedMonth) { oldValue, newValue in 
                updateSelectedDate() 
            }
            .navigationTitle("select_month".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        onDateSelected()
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
        }
    }
}

// Hacer los mismos cambios en QuarterYearPicker y YearPicker

#Preview {
    ExportCSVView()
} 
