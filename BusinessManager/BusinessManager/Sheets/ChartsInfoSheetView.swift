import SwiftUI

struct ChartsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("analytics_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("analytics_description".localized())
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
                    Text("overview".localized())
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Text("how_create_charts".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("charts_creation_description".localized())
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
                    Text("creating_reports".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Text("Chart Types")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The Chart Type selector offers different ways to visualize your data. Switch between Productivity trends, Efficiency distribution, and Performance metrics to get the most relevant view of your team's progress. Each chart type provides unique insights into different aspects of department performance.")
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
                    Text("Chart Types")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Yearly Analysis")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The Yearly Analysis view offers a broader perspective on organizational performance. By examining annual data, you can spot seasonal patterns and long-term trends, making it an essential tool for strategic planning and year-over-year performance assessment.")
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
                    Text("Yearly Analysis")
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ok".localized()) {
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
