import SwiftUI
import SwiftData

struct YearlySummaryView: View {
    let year: Int
    let reports: [Report]
    @State private var isLoading = true
    @State private var yearlySummary: [String: (finishedTasks: Int, totalPerformance: Int, totalVolumeOfWork: Int, reportCount: Int)] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Yearly Summary...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    List {
                        ForEach(yearlySummary.keys.sorted(), id: \.self) { department in
                            let summary = yearlySummary[department]!
                            let averagePerformance = summary.reportCount > 0 ? summary.totalPerformance / summary.reportCount : 0
                            let averageVolumeOfWork = summary.reportCount > 0 ? summary.totalVolumeOfWork / summary.reportCount : 0
                            
                            VStack {
                                Text(department)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    CircularProgressBar(percentage: averagePerformance, title: "Efficiency")
                                    Spacer()
                                    CircularProgressBar(percentage: averageVolumeOfWork, title: "Workload")
                                    Spacer()
                                    VStack {
                                        Text("\(summary.finishedTasks)")
                                            .font(.title)
                                            .bold()
                                        Text("Finished Tasks")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Yearly Summary for \(year)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadYearlySummary()
            }
        }
    }

    private func loadYearlySummary() {
        // Reset summary
        yearlySummary = [:]
        
        for report in reports {
            let reportYear = Calendar.current.component(.year, from: report.date)
            if reportYear == year {
                if yearlySummary[report.departmentName] == nil {
                    yearlySummary[report.departmentName] = (finishedTasks: report.numberOfFinishedTasks, totalPerformance: report.performanceMark, totalVolumeOfWork: report.volumeOfWorkMark, reportCount: 1)
                } else {
                    yearlySummary[report.departmentName]!.finishedTasks += report.numberOfFinishedTasks
                    yearlySummary[report.departmentName]!.totalPerformance += report.performanceMark
                    yearlySummary[report.departmentName]!.totalVolumeOfWork += report.volumeOfWorkMark
                    yearlySummary[report.departmentName]!.reportCount += 1
                }
            }
        }
        
        isLoading = false
    }
} 