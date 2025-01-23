import SwiftUI
import SwiftData

struct ChartsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("iCloudSync") private var iCloudSync = false
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
        
        var localizedName: String {
            rawValue.localized()
        }
        
        var icon: String {
            switch self {
            case .productivity:
                return "chart.line.uptrend.xyaxis"
            case .efficiency:
                return "gauge.medium"
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
                        Label("no_charts_data".localized(), systemImage: "chart.bar")
                            .font(.title2)
                    }, description: {
                        Text("start_adding_reports_charts".localized())
                            .foregroundStyle(.secondary)
                    }, actions: {
                        Button("go_to_reports".localized()) {
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
                                        .frame(maxWidth: .infinity)
                                    
                                case .efficiency:
                                    WorkloadChartView()
                                        .transition(.opacity)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("analytics".localized())
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet2) {
                ChartsInfoSheetView()
                    .presentationDetents([.height(550)])
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("settings".localized(), systemImage: "gear")
                                .symbolRenderingMode(.hierarchical)
                        }
                        Button(action: { isShowingItemSheet2 = true }) {
                            Label("information".localized(), systemImage: "info.circle")
                                
                        }
                        Label("iCloud".localized(), systemImage: iCloudSync ? "checkmark.icloud" : "xmark.icloud")
                            .foregroundStyle(iCloudSync ? .green : .red)
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
}

#Preview {
    ChartsView(selectedTab: .constant(0))
}
