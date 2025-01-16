import SwiftUI
import SwiftData
import Charts

struct WorkloadChartView: View {
    @Query var reports: [Report]
    @State private var selectedData: ChartData?
    
    var chartData: [ChartData] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // Primero filtramos por año y mes
        let filteredReports = reports.filter {
            let reportYear = Calendar.current.component(.year, from: $0.date)
            let reportMonth = Calendar.current.component(.month, from: $0.date)
            return reportYear == currentYear && reportMonth == currentMonth
        }
        
        // Primero agrupamos por departamento
        let reportsByDepartment = Dictionary(grouping: filteredReports) { $0.departmentName }
        
        var result: [ChartData] = []
        
        // Para cada departamento, agrupamos por día
        for (_, departmentReports) in reportsByDepartment {
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: departmentReports) { report in
                calendar.startOfDay(for: report.date)
            }
            
            // Procesamos cada día
            for (date, dailyReports) in groupedByDay {
                // Sumamos todas las tareas del día
                let totalTasksCreated = dailyReports.reduce(0) { $0 + $1.totalTasksCreated }
                let tasksCompletedOnTime = dailyReports.reduce(0) { $0 + $1.tasksCompletedWithoutDelay }
                let totalTasksCompleted = dailyReports.reduce(0) { $0 + $1.numberOfFinishedTasks }
                
                // Calculamos las métricas basadas en los totales
                let performanceMark = totalTasksCreated > 0 ? 
                    Double(tasksCompletedOnTime) / Double(totalTasksCreated) * 100 : 0
                let volumeOfWorkMark = totalTasksCreated > 0 ? 
                    Double(totalTasksCompleted) / Double(totalTasksCreated) * 100 : 0
                
                result.append(ChartData(
                    date: date,
                    departmentName: dailyReports[0].departmentName,
                    performanceMark: Int(round(performanceMark)),
                    volumeOfWorkMark: Int(round(volumeOfWorkMark)),
                    numberOfFinishedTasks: totalTasksCompleted
                ))
            }
        }
        
        return result
    }
    
    var groupedReports: [String: [ChartData]] {
        Dictionary(grouping: chartData, by: { $0.departmentName })
    }

    private func findClosestDataPoint(at location: CGPoint, in proxy: ChartProxy, for departmentData: [ChartData], geometry: GeometryProxy) -> ChartData? {
        guard let plotFrame = proxy.plotFrame else { return nil }
        let x = location.x - geometry[plotFrame].origin.x
        let y = location.y - geometry[plotFrame].origin.y
        
        guard let volume: Double = proxy.value(atX: x),
              let performance: Double = proxy.value(atY: y) else { return nil }
        
        return departmentData.min(by: {
            let distance1 = pow(Double($0.volumeOfWorkMark) - volume, 2) + pow(Double($0.performanceMark) - performance, 2)
            let distance2 = pow(Double($1.volumeOfWorkMark) - volume, 2) + pow(Double($1.performanceMark) - performance, 2)
            return distance1 < distance2
        })
    }
    
    private func selectedDataAnnotation(for data: ChartData) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("\("volume".localized()): \(data.volumeOfWorkMark)%")
                .font(.callout)
            Text("\("performance".localized()): \(data.performanceMark)%")
                .font(.callout)
                .bold()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private func createChartContent(for departmentData: [ChartData], department: String) -> some View {
        Chart(departmentData) { data in
            PointMark(
                x: .value("volume_of_work".localized(), data.volumeOfWorkMark),
                y: .value("performance".localized(), data.performanceMark)
            )
            .foregroundStyle(Color.accentColor)
            .symbol(by: .value("department".localized(), data.departmentName))
            
            if let selected = selectedData, selected.departmentName == department {
                RuleMark(
                    x: .value("Selected X", selected.volumeOfWorkMark)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                
                RuleMark(
                    y: .value("Selected Y", selected.performanceMark)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                
                PointMark(
                    x: .value("volume_of_work".localized(), selected.volumeOfWorkMark),
                    y: .value("performance".localized(), selected.performanceMark)
                )
                .foregroundStyle(.primary)
                .annotation(position: annotationPosition(for: selected)) {
                    selectedDataAnnotation(for: selected)
                }
            }
        }
        .chartXScale(domain: 0...100)
        .chartYScale(domain: 0...100)
        .chartScrollableAxes([])
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: 0.2) { pressing in
                        if !pressing {
                            selectedData = nil
                        }
                    } perform: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let closest = findClosestDataPoint(
                                    at: value.location,
                                    in: proxy,
                                    for: departmentData,
                                    geometry: geometry
                                ) {
                                    withAnimation(.none) {
                                        selectedData = closest
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedData = nil
                            }
                    )
            }
        }
    }

    private func annotationPosition(for data: ChartData) -> AnnotationPosition {
        let thresholdX = 20
        let thresholdY = 20
        
        if data.volumeOfWorkMark < thresholdX {
            return .trailing
        } else if data.volumeOfWorkMark > (100 - thresholdX) {
            return .leading
        }
        
        if data.performanceMark < thresholdY {
            return .top
        } else if data.performanceMark > (100 - thresholdY) {
            return .bottom
        }
        
        return .top
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                ForEach(groupedReports.keys.sorted(), id: \.self) { department in
                    VStack(spacing: 20) {
                        Text(department)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        if let departmentData = groupedReports[department] {
                            createChartContent(for: departmentData, department: department)
                                .chartXAxis {
                                    AxisMarks()
                                }
                                .chartYAxis {
                                    AxisMarks()
                                }
                                .aspectRatio(1.0, contentMode: .fit)
                                .padding()
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    WorkloadChartView()
}
