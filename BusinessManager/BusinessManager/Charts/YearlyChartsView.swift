import SwiftUI
import SwiftData
import Charts

struct YearlyChartsView: View {
    @Query var reports: [Report]
    
    var yearlyData: [Int: [ChartData]] {
        let chartData = reports.map { ChartData(from: $0) }
        return Dictionary(grouping: chartData, by: { Calendar.current.component(.year, from: $0.date) })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(yearlyData.keys.sorted(), id: \.self) { year in
                    NavigationLink(destination: YearChartsView(year: year, data: yearlyData[year]!)) {
                        Text("\(year)")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Yearly Charts")
        }
    }
}

#Preview {
    YearlyChartsView()
} 
