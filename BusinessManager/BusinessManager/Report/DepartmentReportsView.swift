import SwiftUI

struct DepartmentReportsView: View {
    let departmentReports: [Report]
    @Environment(\.modelContext) var context
    @State private var reportToEdit: Report?

    var body: some View {
        List {
            Section(header: Text(departmentReports.first?.departmentName ?? "Department")) {
                ForEach(
                    departmentReports.sorted(by: { $0.date < $1.date })
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
                    do {
                        try context.save()
                    } catch {
                        print("Failed to save context: \(error)")
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