import SwiftUI

struct ChartsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("Analytics Overview")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Analytics visualize key metrics: the Productivity Chart tracks performance trends, the Workload Chart compares performance with workload using a scatter plot to highlight efficiency, and the Performance Chart displays average workload versus completed tasks in a bar chart, measuring efficiency.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("charts1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Overview")
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Text("How to Create Charts")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Charts are generated from report data, processing performance, workload, and completed tasks to create visual insights. They highlight trends, efficiency, and productivity by transforming raw data into actionable information for each department.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("charts2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Creating Reports")
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Text("Chart Controls")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Use the date picker in the toolbar to select different time periods. The calendar icon lets you switch between monthly, quarterly, and yearly views. This helps you analyze trends across different time frames.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("charts3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Controls")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Chart Actions")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The share button allows you to export and share charts. Use the filter button to focus on specific departments or metrics. The refresh button updates the charts with the latest data.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("charts4")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Actions")
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ok") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChartsInfoSheetView()
}
