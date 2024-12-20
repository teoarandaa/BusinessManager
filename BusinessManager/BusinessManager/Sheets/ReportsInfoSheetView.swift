import SwiftUI

struct ReportsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("reports_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("reports_description".localized())
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
                    Text("overview".localized())
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Text("how_to_create_reports".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("create_reports_description".localized())
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
                        Text("monthly_summary_title".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("monthly_summary_description".localized())
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
                        Text("add_report_title".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("add_report_description".localized())
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
                    Button("ok".localized()) {
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
