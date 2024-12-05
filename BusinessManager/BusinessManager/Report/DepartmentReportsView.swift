import SwiftUI

struct DepartmentReportsView: View {
    let departmentReports: [Report]
    
    var body: some View {
        let reportsByYear = Dictionary(grouping: departmentReports, by: { Calendar.current.component(.year, from: $0.date) })
        
        List {
            ForEach(reportsByYear.keys.sorted(), id: \.self) { year in
                if let reportsForYear = reportsByYear[year] {
                    NavigationLink(destination: YearReportsView(reports: reportsForYear, year: year)) {
                        Text("\(year)")
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Reports by Year")
        .navigationBarTitleDisplayMode(.inline)
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

        VStack {
            Picker("Select Month", selection: $selectedMonth) {
                Text("All").tag(nil as Int?)
                ForEach(months, id: \.self) { month in
                    Text(monthName(for: month)).tag(month as Int?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            List {
                ForEach(months, id: \.self) { month in
                    if selectedMonth == nil || selectedMonth == month {
                        if let reportsForMonth = reportsByMonth[month] {
                            Section(header: Text(monthName(for: month))) {
                                ForEach(reportsForMonth) { report in
                                    HStack {
                                        ReportCell(report: report)
                                            .onTapGesture {
                                                reportToEdit = report
                                            }
                                        Button(action: {
                                            reportToView = report
                                        }) {
                                            Image(systemName: "info.circle")
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteReports)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Reports for \(year)")
        .navigationBarTitleDisplayMode(.inline)
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
        return dateFormatter.monthSymbols[month - 1]
    }
}

struct ReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: Report
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    Text(report.date, format: .dateTime.year().month(.abbreviated).day())
                }
                
                Section("Department") {
                    Text(report.departmentName)
                }
                
                Section("Performance") {
                    Text("\(report.performanceMark)%")
                }
                
                Section("Volume of Work") {
                    Text("\(report.volumeOfWorkMark)%")
                }
                
                Section("Finished Tasks") {
                    Text("\(report.numberOfFinishedTasks)")
                }
                
                if !report.annotations.isEmpty {
                    Section("Annotations") {
                        Text(report.annotations)
                    }
                }
            }
            .navigationTitle("Report Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 
