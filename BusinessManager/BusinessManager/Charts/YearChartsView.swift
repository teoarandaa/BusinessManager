import SwiftUI
import SwiftData
import Charts

struct YearChartsView: View {
    let year: Int
    let data: [ChartData]
    let reports: [Report]
    
    // Define colors for each month
    let monthColors: [Int: Color] = [
        1: .red, 2: .orange, 3: .yellow, 4: .green,
        5: .blue, 6: .purple, 7: .pink, 8: .teal,
        9: .brown, 10: .cyan, 11: .indigo, 12: .mint
    ]
    
    @State private var isShowingYearlySummary = false
    @State private var isShowingDepartmentFilter = false
    @State private var selectedDepartments: Set<String> = []
    
    // Add computed property for departments
    private var availableDepartments: [String] {
        Array(Set(data.map { $0.departmentName })).sorted()
    }
    
    // Procesar los datos para agrupar por día
    var processedData: [ChartData] {
        let filteredData = selectedDepartments.isEmpty ? data : data.filter { selectedDepartments.contains($0.departmentName) }
        let reportsByDepartment = Dictionary(grouping: filteredData) { $0.departmentName }
        
        var result: [ChartData] = []
        
        // Para cada departamento, agrupamos por día
        for (_, departmentData) in reportsByDepartment {
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: departmentData) { data in
                calendar.startOfDay(for: data.date)
            }
            
            // Procesamos cada día
            for (date, dailyData) in groupedByDay {
                // Calcular promedios
                let avgPerformance = dailyData.reduce(0) { $0 + $1.performanceMark } / dailyData.count
                let avgVolume = dailyData.reduce(0) { $0 + $1.volumeOfWorkMark } / dailyData.count
                let totalTasks = dailyData.reduce(0) { $0 + $1.numberOfFinishedTasks }
                
                result.append(ChartData(
                    date: date,
                    departmentName: dailyData[0].departmentName,
                    performanceMark: avgPerformance,
                    volumeOfWorkMark: avgVolume,
                    numberOfFinishedTasks: totalTasks
                ))
            }
        }
        
        return result.sorted(by: { $0.date < $1.date })
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

    private func annotationPosition(for data: ChartData, in dateRange: (min: Date, max: Date)) -> AnnotationPosition {
        let threshold = 0.2 // 20% del rango
        let range = dateRange.max.timeIntervalSince(dateRange.min)
        let position = data.date.timeIntervalSince(dateRange.min)
        let ratio = position / range
        
        if ratio < threshold {
            return .trailing
        } else if ratio > (1 - threshold) {
            return .leading
        }
        return .top
    }
    
    private func workloadAnnotationPosition(for data: ChartData) -> AnnotationPosition {
        let thresholdX = 20 // 20% del rango (0-100)
        let thresholdY = 20
        
        // Comprobamos las esquinas primero
        if data.volumeOfWorkMark < thresholdX && data.performanceMark < thresholdY {
            return .trailing // Esquina inferior izquierda
        } else if data.volumeOfWorkMark < thresholdX && data.performanceMark > (100 - thresholdY) {
            return .trailing // Esquina superior izquierda
        } else if data.volumeOfWorkMark > (100 - thresholdX) && data.performanceMark < thresholdY {
            return .leading // Esquina inferior derecha
        } else if data.volumeOfWorkMark > (100 - thresholdX) && data.performanceMark > (100 - thresholdY) {
            return .leading // Esquina superior derecha
        }
        
        // Si no está en una esquina, comprobamos los bordes
        if data.volumeOfWorkMark < thresholdX {
            return .trailing // Borde izquierdo
        } else if data.volumeOfWorkMark > (100 - thresholdX) {
            return .leading // Borde derecho
        } else if data.performanceMark < thresholdY {
            return .top // Borde inferior
        } else if data.performanceMark > (100 - thresholdY) {
            return .bottom // Borde superior
        }
        
        // Si no está cerca de ningún borde, lo ponemos arriba
        return .top
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                // Productivity Chart
                VStack(spacing: 20) {
                    Text("productivity".localized())
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    let dateRange = processedData.reduce(into: (min: Date(), max: Date())) { result, data in
                        result.min = min(result.min, data.date)
                        result.max = max(result.max, data.date)
                    }
                    
                    Chart {
                        ForEach(processedData) { data in
                            LineMark(
                                x: .value("date".localized(), data.date),
                                y: .value("performance".localized(), data.performanceMark)
                            )
                            .foregroundStyle(by: .value("department".localized(), data.departmentName))
                            .symbol(by: .value("department".localized(), data.departmentName))
                        }
                    }
                    .chartXScale(domain: dateRange.min...dateRange.max)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) {
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks()
                    }
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                // Workload Chart
                VStack(spacing: 20) {
                    Text("workload".localized())
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Chart(processedData) { data in
                        PointMark(
                            x: .value("volume_of_work".localized(), data.volumeOfWorkMark),
                            y: .value("performance".localized(), data.performanceMark)
                        )
                        .foregroundStyle(monthColors[Calendar.current.component(.month, from: data.date)] ?? .black)
                        .symbol(by: .value("department".localized(), data.departmentName))
                    }
                    .chartXScale(domain: 0...100)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks()
                    }
                    .chartYAxis {
                        AxisMarks()
                    }
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()

                    // Legend
                    HStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(1..<13) { month in
                                HStack {
                                    Circle()
                                        .fill(monthColors[month] ?? .black)
                                        .frame(width: 10, height: 10)
                                    Text(DateFormatter().monthSymbols[month - 1].capitalized)
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            }
        }
        .navigationTitle(String(format: "charts_for".localized(), String(year)))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingYearlySummary = true
                } label: {
                    Label("yearly_summary".localized(), systemImage: "calendar.badge.clock")
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingDepartmentFilter = true
                } label: {
                    Label("select_departments".localized(), systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingYearlySummary) {
            YearlySummaryView(year: year, reports: reports)
        }
        .sheet(isPresented: $isShowingDepartmentFilter) {
            NavigationView {
                VStack(spacing: 0) {
                    List {
                        Section {
                            ForEach(availableDepartments, id: \.self) { department in
                                Button {
                                    if selectedDepartments.contains(department) {
                                        selectedDepartments.remove(department)
                                    } else {
                                        selectedDepartments.insert(department)
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(department)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if selectedDepartments.contains(department) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                                .imageScale(.medium)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray.opacity(0.5))
                                                .imageScale(.medium)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 4)
                                }
                            }
                        } header: {
                            Text("\(selectedDepartments.count) / \(availableDepartments.count)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    // Footer con información
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("departments".localized())
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
                .navigationTitle("select_departments".localized())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if selectedDepartments.count == availableDepartments.count {
                                selectedDepartments.removeAll()
                            } else {
                                selectedDepartments = Set(availableDepartments)
                            }
                        } label: {
                            Text("all".localized())
                                .fontWeight(.medium)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingDepartmentFilter = false
                        } label: {
                            Text("done".localized())
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    YearChartsView(year: 2024, data: [], reports: [])
} 
