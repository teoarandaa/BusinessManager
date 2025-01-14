import SwiftUI
import SwiftData

struct AdvancedFilters {
    var dateRange: ClosedRange<Date>?
    var performanceRange: (min: Int, max: Int)
    var volumeRange: (min: Int, max: Int)
    var tasksRange: (min: Int, max: Int)
    var tasksCompletedRange: (min: Int, max: Int)
    var finishedTasksRange: (min: Int, max: Int)
    
    static var `default`: AdvancedFilters {
        AdvancedFilters(
            dateRange: nil,
            performanceRange: (0, 100),
            volumeRange: (0, 100),
            tasksRange: (0, 1000),
            tasksCompletedRange: (0, 1000),
            finishedTasksRange: (0, 1000)
        )
    }
}

struct DepartmentReportsView: View {
    @Environment(\.modelContext) var context
    let departmentName: String
    @State private var showingFilters = false
    @State private var filters = AdvancedFilters.default
    
    var availableYears: [Int] {
        let fetchDescriptor = FetchDescriptor<Report>(
            predicate: #Predicate<Report> { report in
                report.departmentName == departmentName
            }
        )
        
        let reports = try? context.fetch(fetchDescriptor)
        let years = Set(reports?.map { Calendar.current.component(.year, from: $0.date) } ?? [])
        return Array(years).sorted(by: >)
    }
    
    var body: some View {
        List(availableYears, id: \.self) { year in
            NavigationLink(destination: YearReportsView(departmentName: departmentName, year: year, filters: filters)) {
                Text(String(year))
                    .font(.headline)
            }
        }
        .navigationTitle(departmentName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingFilters = true
                } label: {
                    Label("filters".localized(), systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet(filters: $filters)
        }
    }
}

struct YearReportsView: View {
    @Environment(\.modelContext) var context
    let departmentName: String
    let year: Int
    let filters: AdvancedFilters
    @State private var reportToEdit: Report?
    @State private var reportToView: Report?
    
    var reports: [Report] {
        let fetchDescriptor = FetchDescriptor<Report>(
            predicate: #Predicate<Report> { report in
                report.departmentName == departmentName
            },
            sortBy: [SortDescriptor(\Report.date, order: .reverse)]
        )
        
        let allReports = (try? context.fetch(fetchDescriptor)) ?? []
        return allReports.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }
    }
    
    var filteredReports: [Report] {
        reports.filter { report in
            if let dateRange = filters.dateRange {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: dateRange.lowerBound)
                let endDate = calendar.date(byAdding: .day, value: 1, to: dateRange.upperBound)!
                let endOfDay = calendar.startOfDay(for: endDate)
                
                guard report.date >= startOfDay && report.date < endOfDay else { return false }
            }
            
            return report.performanceMark >= filters.performanceRange.min &&
                   report.performanceMark <= filters.performanceRange.max &&
                   report.volumeOfWorkMark >= filters.volumeRange.min &&
                   report.volumeOfWorkMark <= filters.volumeRange.max &&
                   report.totalTasksCreated >= filters.tasksRange.min &&
                   report.totalTasksCreated <= filters.tasksRange.max &&
                   report.tasksCompletedWithoutDelay >= filters.tasksCompletedRange.min &&
                   report.tasksCompletedWithoutDelay <= filters.tasksCompletedRange.max &&
                   report.numberOfFinishedTasks >= filters.finishedTasksRange.min &&
                   report.numberOfFinishedTasks <= filters.finishedTasksRange.max
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredReports) { report in
                HStack {
                    ReportCell(report: report)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            reportToEdit = report
                        }
                    
                    Image(systemName: "eye")
                        .foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            reportToView = report
                        }
                        .padding(.leading, 8)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(filteredReports[index])
                }
                do {
                    try context.save()
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } catch {
                    print("Failed to delete report: \(error)")
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
        .navigationTitle("\(departmentName) - \(year)")
        .sheet(item: $reportToEdit) { report in
            UpdateReportSheet(report: report)
        }
        .sheet(item: $reportToView) { report in
            ReportDetailView(report: report)
        }
        .overlay {
            if filteredReports.isEmpty {
                ContentUnavailableView {
                    Label("no_results".localized(), systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text("try_adjusting_filters".localized())
                }
            }
        }
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: AdvancedFilters
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var useDateFilter = false
    
    // Estados temporales para los TextFields
    @State private var minPerformance: String = ""
    @State private var maxPerformance: String = ""
    @State private var minVolume: String = ""
    @State private var maxVolume: String = ""
    @State private var minTasks: String = ""
    @State private var maxTasks: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("filter_by_date".localized()) {
                    Toggle("date_range".localized(), isOn: $useDateFilter)
                    
                    if useDateFilter {
                        DatePicker("from".localized(), selection: $startDate, displayedComponents: .date)
                        DatePicker("to".localized(), selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section("performance_percentage".localized()) {
                    HStack {
                        Text("min".localized())
                        TextField("0", text: $minPerformance)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("max".localized())
                        TextField("100", text: $maxPerformance)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("volume_work_percent".localized()) {
                    HStack {
                        Text("min".localized())
                        TextField("0", text: $minVolume)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("max".localized())
                        TextField("100", text: $maxVolume)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("tasks_percent".localized()) {
                    HStack {
                        Text("min".localized())
                        TextField("0", text: $minTasks)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("max".localized())
                        TextField("1000", text: $maxTasks)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("filters".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("reset".localized()) {
                        resetFilters()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("apply".localized()) {
                        applyFilters()
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeFields()
            }
        }
    }
    
    private func initializeFields() {
        minPerformance = "\(filters.performanceRange.min)"
        maxPerformance = "\(filters.performanceRange.max)"
        minVolume = "\(filters.volumeRange.min)"
        maxVolume = "\(filters.volumeRange.max)"
        minTasks = "\(filters.tasksRange.min)"
        maxTasks = "\(filters.tasksRange.max)"
        
        if let range = filters.dateRange {
            useDateFilter = true
            startDate = range.lowerBound
            endDate = range.upperBound
        }
    }
    
    private func resetFilters() {
        filters = .default
        initializeFields()
        useDateFilter = false
        
        // Añadir feedback háptico
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func applyFilters() {
        if useDateFilter {
            filters.dateRange = startDate...endDate
        } else {
            filters.dateRange = nil
        }
        
        filters.performanceRange = (
            min: Int(minPerformance) ?? 0,
            max: Int(maxPerformance) ?? 100
        )
        
        filters.volumeRange = (
            min: Int(minVolume) ?? 0,
            max: Int(maxVolume) ?? 100
        )
        
        filters.tasksRange = (
            min: Int(minTasks) ?? 0,
            max: Int(maxTasks) ?? 1000
        )
        
        // Añadir feedback háptico
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: Report
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text("date".localized())
                        }
                        .bold()
                        Spacer()
                        Text(report.date, format: .dateTime.year().month(.abbreviated).day())
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "building")
                            Text("department".localized())
                        }
                        .bold()
                        Spacer()
                        Text(report.departmentName)
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("performance".localized())
                        }
                        .bold()
                        Spacer()
                        Text("\(report.performanceMark)%")
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "document.on.document")
                            Text("volume_of_work".localized())
                        }
                        .bold()
                        Spacer()
                        Text("\(report.volumeOfWorkMark)%")
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("finished_tasks".localized())
                        }
                        .bold()
                        Spacer()
                        Text("\(report.numberOfFinishedTasks)")
                    }
                    
                    if !report.annotations.isEmpty {
                        HStack {
                            HStack {
                                Image(systemName: "pencil")
                                Text("annotations".localized())
                            }
                            .bold()
                            Spacer()
                            Text(report.annotations)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("report_details".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("done".localized()) { dismiss() }
                }
            }
        }
    }
} 
