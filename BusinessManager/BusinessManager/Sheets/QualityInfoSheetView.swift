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
                        Text("Department Filter")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The Department Filter enhances your analysis capabilities by allowing you to focus on specific time periods and departments. This targeted approach helps identify strengths and areas for improvement, supporting better decision-making about resources and processes.")
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
                    Text("Filters")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Threshold Settings")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Threshold Settings help establish and maintain quality standards across your organization. By setting minimum performance levels and benchmarks, you create clear targets and early warning indicators, enabling proactive management of your quality standards.")
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
                    Text("Thresholds")
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
