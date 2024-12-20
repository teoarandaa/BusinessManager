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
                    ProgressView("loading_monthly_summary".localized())
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if monthlySummary.isEmpty {
                        ContentUnavailableView(label: {
                            Label("no_monthly_reports".localized(), systemImage: "calendar.badge.exclamationmark")
                        }, description: {
                            Text("no_reports_current_month".localized())
                        })
                        .offset(y: -60)
                    } else {
                        List {
                            ForEach(monthlySummary.keys.sorted(), id: \.self) { department in
                                let summary = monthlySummary[department]!
                                let averagePerformance = summary.reportCount > 0 ? summary.totalPerformance / summary.reportCount : 0
                                let averageVolumeOfWork = summary.reportCount > 0 ? summary.totalVolumeOfWork / summary.reportCount : 0
                                
                                VStack {
                                    Text(department)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.bottom, 10)
                                    
                                    HStack {
                                        CircularProgressBar(percentage: averagePerformance, title: "efficiency".localized())
                                        Spacer()
                                        CircularProgressBar(percentage: averageVolumeOfWork, title: "workload".localized())
                                        Spacer()
                                        VStack {
                                            Text("\(summary.finishedTasks)")
                                                .font(.title)
                                                .bold()
                                            Text("finished_tasks".localized())
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
            }
            .navigationTitle("monthly_summary".localized())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMonthlySummary()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("close".localized()) {
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

struct CircularProgressBar: View {
    var percentage: Int
    var title: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .frame(width: 90, height: 90)
                .foregroundStyle(Color.gray.opacity(0.3))

            Circle()
                .trim(from: 0, to: CGFloat(percentage) / 100)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .frame(width: 90, height: 90)
                .foregroundStyle(Color.accentColor)
                .rotationEffect(.degrees(-90))

            VStack {
                Text("\(percentage)%")
                    .font(.body)
                    .bold()
                    .monospacedDigit()
                Text(title)
                    .font(.caption2)
            }
        }
    }
} 
