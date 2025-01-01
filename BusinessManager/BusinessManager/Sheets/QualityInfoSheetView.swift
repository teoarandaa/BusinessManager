import SwiftUI

struct QualityInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("quality_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("quality_description".localized())
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
                    Text("overview".localized())
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Text("how_create_metrics".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("metrics_description".localized())
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
                    Text("metrics".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Text("department_filter".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("filter_description".localized())
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
                    Text("filters".localized())
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("threshold_settings".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("threshold_description".localized())
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
                    Text("thresholds".localized())
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
    QualityInfoSheetView()
}
