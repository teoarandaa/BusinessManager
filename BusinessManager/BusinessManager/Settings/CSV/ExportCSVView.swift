import SwiftUI
import SwiftData

enum ExportPeriod: String, CaseIterable {
    case week = "weekly"
    case month = "monthly"
    case year = "yearly"
    
    var localizedName: String {
        rawValue.localized()
    }
}

struct ExportCSVView: View {
    @Environment(\.modelContext) private var context
    @Query private var reports: [Report]
    
    @State private var selectedPeriod: ExportPeriod = .month
    @State private var selectedDepartment = "all_departments".localized()
    @State private var departments: [String] = []
    @State private var showShareSheet = false
    @State private var csvURL: URL?
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        List {
            Section("filters".localized()) {
                // Period Picker
                Picker("period".localized(), selection: $selectedPeriod) {
                    ForEach(ExportPeriod.allCases, id: \.self) { period in
                        Text(period.localizedName).tag(period)
                    }
                }
                
                // Department Picker
                Picker("department".localized(), selection: $selectedDepartment) {
                    Text("all_departments".localized())
                        .tag("all_departments".localized())
                    ForEach(departments, id: \.self) { department in
                        Text(department).tag(department)
                    }
                }
            }
            
            Section {
                Button(action: prepareAndShowShareSheet) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("export_csv".localized())
                    }
                }
            }
        }
        .navigationTitle("export_csv".localized())
        .onAppear {
            loadDepartments()
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
        let now = Date()
        
        let isInSelectedPeriod: Bool
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            isInSelectedPeriod = report.date >= weekAgo
            
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            isInSelectedPeriod = report.date >= monthAgo
            
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            isInSelectedPeriod = report.date >= yearAgo
        }
        
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