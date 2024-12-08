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

    var body: some View {
        NavigationStack {
            VStack {
                if reports.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Charts", systemImage: "chart.bar")
                    }, description: {
                        Text("Start adding reports to see your charts.")
                    }, actions: {
                        Button("Go to Reports") {
                            selectedTab = 0
                        }
                    })
                    .offset(y: -60)
                } else {
                    Picker("Charts", selection: $chart) {
                        ForEach(chartOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: chart) {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    }
                    
                    Group {
                        switch chart {
                        case "Productivity":
                            ProductivityChartView()
                        case "Efficiency":
                            WorkloadChartView()
                        case "Performance":
                            PerformanceChartView()
                        default:
                            Text("Select a chart")
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Charts")
            .sheet(isPresented: $isShowingItemSheet2) {
                ChartsInfoSheetView()
                    .presentationDetents([.height(700)])
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        isShowingItemSheet2 = true
                    }) {
                        Label("Information", systemImage: "info.circle")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink(destination: YearlyChartsView()) {
                        Label("Yearly Charts", systemImage: "calendar")
                    }
                    .disabled(reports.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ChartsView(selectedTab: .constant(0))
}
