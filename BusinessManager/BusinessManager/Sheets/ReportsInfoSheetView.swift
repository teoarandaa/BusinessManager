import SwiftUI

struct ReportsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("Reports Overview")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Reports offer insights into performance, productivity, and progress.\n\nSecurely stored and organized by type and date, they help you track and share results, ensuring quick access for smarter decisions.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("reports1")
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
                        Text("How to Create Reports")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("To create accurate reports, we need the current date, department name, tasks created, tasks completed on-time, and tasks completed (tasks completed on-time is included in this group).\nThis data is then displayed in charts, providing clear insights into productivity, workload, and performance, helping you make informed, data-driven decisions.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("reports2")
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
                        Text("Monthly Summary")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The Monthly Summary feature generates a comprehensive PDF report comparing department performances and trends. This report format makes it easy to review and share key metrics, making it invaluable for management reviews and team evaluations.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("reports3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Monthly Summary")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Add Report")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Adding a new report is a straightforward process for tracking your department's progress. You can input task completion rates, performance metrics, and specific notes about achievements or challenges, building a clear picture of your team's performance over time.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("reports4")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Add Report")
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
    ReportsInfoSheetView()
}
