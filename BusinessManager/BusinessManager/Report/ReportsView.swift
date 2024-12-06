import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @Environment(\.modelContext) var context
    @Query(sort: \Report.departmentName) var reports: [Report]
    @State private var reportToEdit: Report?
    @State private var showingBottomSheet: Bool = false
    @State private var isShowingMonthlySummary = false
    @State private var searchText = ""
    
    var filteredReports: [Report] {
        if searchText.isEmpty {
            return reports
        } else {
            return reports.filter { $0.departmentName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        if !filteredReports.isEmpty {
                            Button("Monthly Summary") {
                                isShowingMonthlySummary = true
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    ForEach(
                        Dictionary(grouping: filteredReports, by: { $0.departmentName })
                            .sorted(by: { $0.key < $1.key }),
                        id: \.key
                    ) { department, departmentReports in
                        NavigationLink(destination: DepartmentReportsView(departmentReports: departmentReports)) {
                            Text(department)
                                .font(.headline)
                        }
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Departments")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet1) {
                    AddReportSheet()
                }
                .sheet(isPresented: $isShowingItemSheet2) {
                    ReportsInfoSheetView()
                        .presentationDetents([.height(600)])
                }
                .sheet(item: $reportToEdit) { report in
                    UpdateReportSheet(report: report)
                }
                .sheet(isPresented: $isShowingMonthlySummary) {
                    MonthlySummaryView()
                }
                .overlay {
                    if reports.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No Reports", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Start adding reports to see your list.")
                        }, actions: {
                            Button("Add Report") { isShowingItemSheet1 = true }
                        })
                        .offset(y: -60)
                    }
                }
            }
            .toolbar {
                if !reports.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Add Task", systemImage: "plus") {
                            isShowingItemSheet1 = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Information", systemImage: "info.circle") {
                        isShowingItemSheet2 = true
                    }
                }
            }
        }
    }
}

#Preview {
    ReportsView()
}

struct ReportCell: View {
    let report: Report
    
    var body: some View {
        HStack {
            Text(report.date, format: .dateTime.year().month(.abbreviated).day())
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(report.departmentName)
                .bold()
            Spacer()
        }
    }
}

struct AddReportSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = .now
    @State private var departmentName: String = ""
    @State private var performanceMark: Int = 0
    @State private var volumeOfWorkMark: Int = 0
    @State private var numberOfFinishedTasks: Int = 0
    @State private var annotations: String = ""
    
    // State variables for alerts
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date")
                        .bold()
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Department name")
                        .bold()
                    Spacer()
                    TextField("", text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Performance")
                        .bold()
                    Spacer()
                    TextField("", value: $performanceMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("", value: $volumeOfWorkMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("", value: $numberOfFinishedTasks, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("", text: $annotations, axis: .vertical)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let currentDate = Date()
                        if date > currentDate {
                            alertMessage = "The report date cannot be in the future."
                            showAlert = true
                        } else {
                            // Create the report
                            let newReport = Report(date: date, departmentName: departmentName, performanceMark: performanceMark, volumeOfWorkMark: volumeOfWorkMark, numberOfFinishedTasks: numberOfFinishedTasks, annotations: annotations)
                            context.insert(newReport)
                            do {
                                try context.save()
                                dismiss()
                            } catch {
                                print("Failed to save report: \(error)")
                            }
                        }
                    }
                }
            }
            .alert("Invalid Date", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct UpdateReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Bindable var report: Report
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date")
                        .bold()
                    Spacer()
                    DatePicker("", selection: $report.date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Department name")
                        .bold()
                    Spacer()
                    TextField("", text: $report.departmentName, axis: .vertical)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Performance")
                        .bold()
                    Spacer()
                    TextField("", value: $report.performanceMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("", value: $report.volumeOfWorkMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("", value: $report.numberOfFinishedTasks, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("", text: $report.annotations, axis: .vertical)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            print("Failed to save updated report: \(error)")
                        }
                    }
                }
            }
        }
    }
}
