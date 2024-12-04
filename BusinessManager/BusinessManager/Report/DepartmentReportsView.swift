import SwiftUI

struct DepartmentReportsView: View {
    let departmentReports: [Report]
    @Environment(\.modelContext) var context
    @State private var reportToEdit: Report?
    @State private var selectedMonth: String = "All"
    
    private var months: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.monthSymbols
    }
    
    private var filteredReports: [Report] {
        if selectedMonth == "All" {
            return departmentReports
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return departmentReports.filter { dateFormatter.string(from: $0.date) == selectedMonth }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Select Month", selection: $selectedMonth) {
                Text("All").tag("All")
                ForEach(months, id: \.self) { month in
                    Text(month).tag(month)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            List {
                ForEach(Dictionary(grouping: filteredReports, by: { Calendar.current.component(.month, from: $0.date) })
                            .sorted(by: { $0.key < $1.key }), id: \.key) { month, reports in
                    Section(header: Text(DateFormatter().monthSymbols[month - 1])) {
                        ForEach(reports.sorted(by: { $0.date < $1.date })) { report in
                            ReportCell(report: report)
                                .onTapGesture {
                                    reportToEdit = report
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let reportToDelete = reports[index]
                                context.delete(reportToDelete)
                            }
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
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $reportToEdit) { report in
                UpdateReportSheet(report: report)
            }
        }
    }
} 