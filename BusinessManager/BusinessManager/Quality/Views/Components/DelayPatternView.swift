import SwiftUI
import Charts

struct DelayPatternView: View {
    let reports: [Report]
    
    private var chartData: [(date: Date, delays: Double)] {
        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: reports) { report in
            calendar.startOfDay(for: report.date)
        }
        
        return groupedByDate.map { date, reports in
            // Si hay más de un reporte por día (múltiples departamentos), calculamos la media
            let averageDelays = reports.map { report -> Double in
                Double(report.totalTasksCreated - report.tasksCompletedWithoutDelay)
            }.reduce(0, +) / Double(reports.count)
            
            return (date: date, delays: averageDelays)
        }
        .sorted { $0.date < $1.date }
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