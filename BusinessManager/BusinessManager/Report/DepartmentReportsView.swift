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
            VStack {
                List {
                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Date")
                        }
                            .bold()
                        Spacer()
                        Text(report.date, format: .dateTime.year().month(.abbreviated).day())
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "building")
                            Text("Department")
                        }
                            .bold()
                        Spacer()
                        Text(report.departmentName)
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Performance")
                        }
                            .bold()
                        Spacer()
                        Text("\(report.performanceMark)%")
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "document.on.document")
                            Text("Volume of Work")
                        }
                            .bold()
                        Spacer()
                        Text("\(report.volumeOfWorkMark)%")
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Finished Tasks")
                        }
                            .bold()
                        Spacer()
                        Text("\(report.numberOfFinishedTasks)")
                    }
                    
                    if !report.annotations.isEmpty {
                        HStack {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Annotations")
                            }
                                .bold()
                            Spacer()
                            Text(report.annotations)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
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
