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
                        Text("Report Controls")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The plus button in the toolbar creates new reports. Use the calendar to select dates and the department picker to choose the relevant team. The save button stores your report data securely.")
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
                    Text("Controls")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Report Actions")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Use the edit button to modify existing reports, the share button to export reports as PDFs, and the delete button to remove outdated reports. The filter button helps organize reports by department or date.")
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
    ReportsInfoSheetView()
}
