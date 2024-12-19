import SwiftUI
import SwiftData

struct ChartsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.modelContext) var context
    @State private var isShowingItemSheet2 = false
    @State private var showingBottomSheet: Bool = false
    @Query(sort: \Report.departmentName) var reports: [Report]
    @Binding var selectedTab: Int
    @State private var isShowingSettings = false
    
    // Definir las opciones como enum para mejor control
    enum ChartType: String, CaseIterable {
        case productivity = "productivity"
        case efficiency = "efficiency"
        case performance = "performance"
        
        var localizedName: String {
            rawValue.localized()
        }
        
        var icon: String {
            switch self {
            case .productivity:
                return "chart.line.uptrend.xyaxis"
            case .efficiency:
                return "gauge.medium"
            case .performance:
                return "chart.bar.fill"
            }
        }
    }
    
    @State private var selectedChart: ChartType = .productivity
    
    var chartIcon: String {
        selectedChart.icon
    }
    
    var uniqueDepartments: [String] {
        Array(Set(reports.map { $0.departmentName })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if reports.isEmpty {
                    
                    ContentUnavailableView(label: {
                        Label("no_quality_data".localized(), systemImage: "chart.bar")
                            .font(.title2)
                    }, description: {
                        Text("start_adding_reports_quality".localized())
                            .foregroundStyle(.secondary)
                    }, actions: {
                        Button("reports".localized()) {
                            selectedTab = 0
                        }
                    })
                    .padding(.bottom, 115)
                } else {
                    ScrollView {
                        VStack(spacing: 35) {
                            // Chart Content
                            Group {
                                switch selectedChart {
                                case .productivity:
                                    ProductivityChartView()
                                        .transition(.opacity)
                                    
                                case .efficiency:
                                    WorkloadChartView()
                                        .transition(.opacity)
                                    
                                case .performance:
                                    PerformanceChartView()
                                        .transition(.opacity)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("analytics".localized())
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet2) {
                ChartsInfoSheetView()
                    .presentationDetents([.height(700)])
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { isShowingSettings = true }) {
                        Label("settings".localized(), systemImage: "gear")
                            .symbolRenderingMode(.hierarchical)
                    }
                    Button(action: { isShowingItemSheet2 = true }) {
                        Label("information".localized(), systemImage: "info.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                if !reports.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            ForEach(ChartType.allCases, id: \.self) { option in
                                Button(action: { 
                                    withAnimation {
                                        selectedChart = option
                                    }
                                    let generator = UISelectionFeedbackGenerator()
                                    generator.selectionChanged()
                                }) {
                                    Label(option.localizedName, systemImage: option.icon)
                                }
                            }
                        } label: {
                            Label("chart_type".localized(), systemImage: chartIcon)
                                .symbolRenderingMode(.hierarchical)
                        }
                        
                        NavigationLink(destination: YearlyChartsView()) {
                            Label("yearly".localized(), systemImage: "calendar")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }
    
    private func getChartIcon(for type: String) -> String {
        switch type {
        case "Productivity":
            return "chart.line.uptrend.xyaxis"
        case "Efficiency":
            return "gauge.medium"
        case "Performance":
            return "chart.bar.fill"
        default:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    private func getChartDescription(for type: String) -> String {
        switch type {
        case "Productivity":
            return "Track your team's productivity trends and patterns"
        case "Efficiency":
            return "Monitor workload distribution and efficiency metrics"
        case "Performance":
            return "Analyze overall performance and goal achievement"
        default:
            return ""
        }
    }
}

#Preview {
    ChartsView(selectedTab: .constant(0))
}
