import SwiftUI

struct ReportsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Image(systemName: "doc.text.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("reports_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("reports_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("overview".localized())
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("how_to_create_reports".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("create_reports_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("Creating Reports")
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Image(systemName: "calendar.badge.clock")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("monthly_summary_title".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("monthly_summary_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("Monthly Summary")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("add_report_title".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("add_report_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
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
