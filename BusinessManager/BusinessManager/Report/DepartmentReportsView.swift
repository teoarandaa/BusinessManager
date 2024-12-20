import SwiftUI

struct AdvancedFilters {
    var dateRange: ClosedRange<Date>?
    var performanceRange: (min: Int, max: Int)
    var volumeRange: (min: Int, max: Int)
    var tasksRange: (min: Int, max: Int)
    
    static var `default`: AdvancedFilters {
        AdvancedFilters(
            dateRange: nil,
            performanceRange: (0, 100),
            volumeRange: (0, 100),
            tasksRange: (0, 1000)
        )
    }
}

struct DepartmentReportsView: View {
    @Environment(\.modelContext) var context
    let departmentReports: [Report]
    @State private var showingFilters = false
    @State private var filters = AdvancedFilters.default
    
    var filteredReports: [Report] {
        var reports = departmentReports
        
        if let dateRange = filters.dateRange {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateRange.lowerBound)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: dateRange.upperBound)!
            
            reports = reports.filter { 
                let reportDate = $0.date
                return reportDate >= startOfDay && reportDate <= endOfDay
            }
        }
        
        reports = reports.filter {
            $0.performanceMark >= filters.performanceRange.min &&
            $0.performanceMark <= filters.performanceRange.max &&
            $0.volumeOfWorkMark >= filters.volumeRange.min &&
            $0.volumeOfWorkMark <= filters.volumeRange.max &&
            $0.numberOfFinishedTasks >= filters.tasksRange.min &&
            $0.numberOfFinishedTasks <= filters.tasksRange.max
        }
        
        return reports
    }
    
    var body: some View {
        let reportsByYear = Dictionary(grouping: filteredReports, by: { Calendar.current.component(.year, from: $0.date) })
        
        List {
            ForEach(reportsByYear.keys.sorted(), id: \.self) { year in
                if let reportsForYear = reportsByYear[year] {
                    NavigationLink(destination: YearReportsView(reports: reportsForYear, year: year)) {
                        Text("\(String(year))")
                            .font(.headline)
                    }
                }
            }
            .onDelete { indexSet in
                let sortedYears = reportsByYear.keys.sorted()
                for index in indexSet {
                    let yearToDelete = sortedYears[index]
                    let reportsToDelete = departmentReports.filter {
                        Calendar.current.component(.year, from: $0.date) == yearToDelete
                    }
                    
                    for report in reportsToDelete {
                        context.delete(report)
                    }
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
        }
        .navigationTitle("reports_by_year".localized())
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
                
                Section("Volume of Work (%)") {
                    HStack {
                        Text("Min:")
                        TextField("0", text: $minVolume)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("Max:")
                        TextField("100", text: $maxVolume)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Tasks") {
                    HStack {
                        Text("Min:")
                        TextField("0", text: $minTasks)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("Max:")
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

struct YearReportsView: View {
    @Environment(\.modelContext) var context
    let reports: [Report]
    let year: Int
    @State private var reportToEdit: Report?
    @State private var reportToView: Report?
    @State private var selectedMonth: Int? = nil

    var body: some View {
        let reportsByMonth = Dictionary(grouping: reports, by: { Calendar.current.component(.month, from: $0.date) })
        let months = reportsByMonth.keys.sorted()
        
        List {
            ForEach(months, id: \.self) { month in
                if selectedMonth == nil || selectedMonth == month {
                    if let reportsForMonth = reportsByMonth[month] {
                        Section(header: Text(monthName(for: month))) {
                            ForEach(reportsForMonth) { report in
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
                            .onDelete(perform: deleteReports)
                        }
                    }
                }
            }
        }
        .navigationTitle("reports_for_year".localized(with: String(year)))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("all".localized()) {
                        selectedMonth = nil
                    }
                    ForEach(months, id: \.self) { month in
                        Button(monthName(for: month)) {
                            selectedMonth = month
                        }
                    }
                } label: {
                    Label("filters".localized(), systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(item: $reportToEdit) { report in
            UpdateReportSheet(report: report)
        }
        .sheet(item: $reportToView) { report in
            ReportDetailView(report: report)
        }
    }

    private func deleteReports(at offsets: IndexSet) {
        for index in offsets {
            let report = reports[index]
            context.delete(report)
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete report: \(error)")
        }
    }
    
    private func monthName(for month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        return dateFormatter.monthSymbols[month - 1].capitalized
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
