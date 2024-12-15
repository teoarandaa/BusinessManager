import SwiftUI
import SwiftData

struct ChartsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var chart: String = "Productivity"
    let chartOptions = ["Productivity", "Efficiency", "Performance"]
    @Environment(\.modelContext) var context
    @State private var isShowingItemSheet2 = false
    @State private var showingBottomSheet: Bool = false
    @Query(sort: \Report.departmentName) var reports: [Report]
    @Binding var selectedTab: Int
    @State private var isShowingSettings = false
    
    var chartIcon: String {
        switch chart {
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
    
    var uniqueDepartments: [String] {
        Array(Set(reports.map { $0.departmentName })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if reports.isEmpty {
                    
                    ContentUnavailableView(label: {
                        Label("No Charts", systemImage: "chart.bar")
                            .font(.title2)
                    }, description: {
                        Text("Start adding reports to see your charts.")
                            .foregroundStyle(.secondary)
                    }, actions: {
                        Button("Go to Reports") {
                            selectedTab = 0
                        }
                    })
                    .padding(.bottom, 115)
                } else {
                    ScrollView {
                        VStack(spacing: 35) {
                            // Chart Content
                            Group {
                                switch chart {
                                case "Productivity":
                                    ProductivityChartView()
                                        .transition(.opacity)
                                    
                                case "Efficiency":
                                    WorkloadChartView()
                                        .transition(.opacity)
                                    
                                case "Performance":
                                    PerformanceChartView()
                                        .transition(.opacity)
                                    
                                default:
                                    Text("Select a chart")
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Charts & Analytics")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet2) {
                ChartsInfoSheetView()
                    .presentationDetents([.height(700)])
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { isShowingItemSheet2 = true }) {
                        Label("Information", systemImage: "info.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                    Button(action: { isShowingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(chartOptions, id: \.self) { option in
                            Button(action: { 
                                withAnimation {
                                    chart = option
                                }
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                            }) {
                                Label(option, systemImage: getChartIcon(for: option))
                            }
                        }
                    } label: {
                        Label("Chart Type", systemImage: chartIcon)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    NavigationLink(destination: YearlyChartsView()) {
                        Label("Yearly", systemImage: "calendar")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .disabled(reports.isEmpty)
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
