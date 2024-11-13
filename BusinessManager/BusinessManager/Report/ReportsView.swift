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
    @State private var isShowingItemSheet = false
    @Environment(\.modelContext) var context
    // @Query(filter: #Predicate<Report> { $0.date >= Date() }, sort: \Report.date)     --> Filtro de los reports
    @Query(sort: \Report.date) var reports: [Report]
    @State private var reportToEdit: Report?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(reports) { report in
                    ReportCell(report: report)
                        .onTapGesture {
                            reportToEdit = report
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(reports[index])
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet) { AddReportSheet() }
            .sheet(item: $reportToEdit) { report in
                UpdateReportSheet(report: report)
            }
            .toolbar {
                if !reports.isEmpty {
                    Button("Add Report", systemImage: "plus") {
                        isShowingItemSheet = true
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
                        Button("Add Report") { isShowingItemSheet = true }
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
            Text(report.departamentName)
        }
    }
}

struct AddReportSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = .now
    @State private var departamentName: String = ""
    @State private var performanceMark: Int = 0
    @State private var volumeOfWorkMark: Int = 0
    @State private var numberOfFinishedTasks: Int = 0
    @State private var annotations: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Departament name", text: $departamentName)
                TextField("Percentatge of performance", value: $performanceMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Percentatge of volume of work", value: $volumeOfWorkMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Number of finished tasks", value: $numberOfFinishedTasks, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Annotations", text: $annotations)
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let report = Report(date: date, departamentName: departamentName, performanceMark: performanceMark, volumeOfWorkMark: volumeOfWorkMark, numberOfFinishedTasks: numberOfFinishedTasks, annotations: annotations)
                        context.insert(report)
                        dismiss()
                    }
                }
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
                TextField("Departament name", text: $report.departamentName)
                TextField("Percentatge of performance", value: $report.performanceMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Percentatge of volume of work", value: $report.volumeOfWorkMark, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Number of finished tasks", value: $report.numberOfFinishedTasks, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Annotations", text: $report.annotations)
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
