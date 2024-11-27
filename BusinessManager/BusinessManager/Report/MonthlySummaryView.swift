import SwiftUI
import SwiftData

struct MonthlySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query var reports: [Report]
    @State private var isLoading = true
    @State private var monthlySummary: [String: (finishedTasks: Int, totalPerformance: Int, totalVolumeOfWork: Int, reportCount: Int)] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Monthly Summary...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    List {
                        ForEach(monthlySummary.keys.sorted(), id: \.self) { department in
                            let summary = monthlySummary[department]!
                            let averagePerformance = summary.reportCount > 0 ? summary.totalPerformance / summary.reportCount : 0
                            let averageVolumeOfWork = summary.reportCount > 0 ? summary.totalVolumeOfWork / summary.reportCount : 0
                            
                            HStack {
                                Text(department)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading) {
                                    Text("Finished Tasks: \(summary.finishedTasks)")
                                    Text("Performance: \(averagePerformance)%")
                                    Text("Workload: \(averageVolumeOfWork)%")
                                }
                                .font(.subheadline)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Monthly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMonthlySummary()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func loadMonthlySummary() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Reset summary
        monthlySummary = [:]
        
        for report in reports {
            let reportDate = Calendar.current.dateComponents([.year, .month], from: report.date)
            if reportDate.year == currentYear && reportDate.month == currentMonth {
                if monthlySummary[report.departmentName] == nil {
                    monthlySummary[report.departmentName] = (finishedTasks: report.numberOfFinishedTasks, totalPerformance: report.performanceMark, totalVolumeOfWork: report.volumeOfWorkMark, reportCount: 1)
                } else {
                    monthlySummary[report.departmentName]!.finishedTasks += report.numberOfFinishedTasks
                    monthlySummary[report.departmentName]!.totalPerformance += report.performanceMark
                    monthlySummary[report.departmentName]!.totalVolumeOfWork += report.volumeOfWorkMark
                    monthlySummary[report.departmentName]!.reportCount += 1
                }
            }
        }
        
        isLoading = false
    }
} 
