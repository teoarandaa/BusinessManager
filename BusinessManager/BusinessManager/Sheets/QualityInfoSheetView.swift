import SwiftUI

struct QualityInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("Quality Overview")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Quality Analysis provides comprehensive insights into department performance, volume of work, and task completion rates. Key metrics are tracked and analyzed to identify trends, helping you maintain high standards and improve efficiency.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("quality1")
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
                        Text("How to create Metrics")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("To create quality metrics, start by tracking task completion times and setting deadlines. Record the number of tasks assigned and completed. Calculate performance based on timely completions, volume of work from task ratios, and overall completion rates. Monitor these metrics regularly to identify trends and areas for improvement.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("quality2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Metrics")
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Text("Quality Controls")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Use the plus button to add new quality insights. The date picker helps track metrics over time, while the department selector ensures you're analyzing the right team. Set minimum thresholds for performance, volume, and completion rates to maintain quality standards.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("quality3")
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
                        Text("Quality Actions")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The refresh button updates metrics with the latest data. Use filters to focus on specific quality aspects or departments. The share button exports quality reports, while the analysis button provides detailed insights into performance trends.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("quality4")
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
    QualityInfoSheetView()
}
