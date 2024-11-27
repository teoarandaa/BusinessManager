//
//  ReportsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

//
//  ReportsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

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
    
    var body: some View {
        NavigationStack {
            List {
                // Agrupamos los reportes por departamento y ordenamos cada grupo
                ForEach(
                    Dictionary(grouping: reports, by: { $0.departmentName })
                        .sorted(by: { $0.key < $1.key }), // Ordenar departamentos por nombre ascendente
                    id: \.key
                ) { department, departmentReports in
                    Section(header: Text(department)) {
                        ForEach(
                            departmentReports.sorted(by: { $0.date < $1.date }) // Ordenar reportes por fecha descendente
                        ) { report in
                            ReportCell(report: report)
                                .onTapGesture {
                                    reportToEdit = report
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let reportToDelete = departmentReports[index]
                                context.delete(reportToDelete)
                            }
                            // Save the context if necessary
                            do {
                                try context.save()
                            } catch {
                                print("Failed to save context: \(error)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reports")
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
            .toolbar {
                if !reports.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Add Report", systemImage: "plus") {
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
    
    // State variables for alert
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Department name", text: $departmentName, axis: .vertical)
                TextField("Performance (%)", value: $performanceMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Volume of work (%)", value: $volumeOfWorkMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Number of finished tasks", value: $numberOfFinishedTasks, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Annotations", text: $annotations, axis: .vertical)
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let currentMonth = Calendar.current.component(.month, from: Date())
                        let reportMonth = Calendar.current.component(.month, from: date)
                        
                        if reportMonth < currentMonth {
                            alertMessage = "The report date cannot be in a previous month."
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
    @Bindable var report: Report
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $report.date, displayedComponents: .date)
                TextField("Department name", text: $report.departmentName, axis: .vertical)
                TextField("Performance (%)", value: $report.performanceMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Volume of work (%)", value: $report.volumeOfWorkMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Number of finished tasks", value: $report.numberOfFinishedTasks, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Annotations", text: $report.annotations, axis: .vertical)
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
