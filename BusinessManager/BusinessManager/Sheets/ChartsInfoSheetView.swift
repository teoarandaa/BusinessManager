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
                        
                        Text("charts_generation".localized())
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
                        Text("chart_types".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("chart_types_description".localized())
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
                    Text("chart_types".localized())
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("yearly_analysis".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("yearly_analysis_description".localized())
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
                    Text("yearly_analysis".localized())
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ok".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
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
