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
        NavigationStack{
            List {
                ForEach(yearlyData.keys.sorted(by: >), id: \.self) { year in
                    let reportsForYear = reports.filter { Calendar.current.component(.year, from: $0.date) == year }
                    NavigationLink(destination: YearChartsView(year: year, data: yearlyData[year]!, reports: reportsForYear)) {
                        Text("\(String(year))")
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
