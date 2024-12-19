import SwiftUI
import Charts

struct ErrorDistributionChart: View {
    let reports: [Report]
    
    private var chartData: [(department: String, delays: Int)] {
        Dictionary(grouping: reports, by: { $0.departmentName })
            .map { department, reports in
                let totalDelays = reports.reduce(0) { $0 + ($1.totalTasksCreated - $1.tasksCompletedWithoutDelay) }
                return (department: department, delays: totalDelays)
            }
            .sorted { $0.delays > $1.delays }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("task_delays_by_department".localized())
                .font(.headline)
            
            Chart(chartData, id: \.department) { item in
                BarMark(
                    x: .value("department".localized(), item.department),
                    y: .value("delayed_tasks".localized(), item.delays)
                )
                .foregroundStyle(.red.opacity(0.8))
            }
            .chartLegend(.hidden)
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ErrorDistributionChart(reports: [])
        .padding()
}