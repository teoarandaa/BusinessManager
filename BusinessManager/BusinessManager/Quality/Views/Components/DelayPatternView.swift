import SwiftUI
import Charts

struct DelayPatternView: View {
    let reports: [Report]
    
    private var chartData: [(date: Date, delays: Int)] {
        reports
            .sorted { $0.date < $1.date }
            .map { report in
                let delays = report.totalTasksCreated - report.tasksCompletedWithoutDelay
                return (date: report.date, delays: delays)
            }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("delay_pattern".localized())
                .font(.headline)
            
            Chart(chartData, id: \.date) { item in
                LineMark(
                    x: .value("date".localized(), item.date),
                    y: .value("delayed_tasks".localized(), item.delays)
                )
                .foregroundStyle(.red)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Delays", item.delays)
                )
                .foregroundStyle(.red.opacity(0.1))
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DelayPatternView(reports: [])
        .padding()
} 