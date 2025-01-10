import SwiftUI

struct QualityInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("quality_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("quality_description".localized())
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
                        Image(systemName: "chart.bar.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("how_create_metrics".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("metrics_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("metrics".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Image(systemName: "folder.fill.badge.gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("department_filter".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("filter_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("filters".localized())
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Image(systemName: "gauge.with.dots.needle.50percent")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("threshold_settings".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("threshold_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("thresholds".localized())
                }
                
                // Fifth Page (Recommendations)
                ScrollView {
                    VStack {
                        Image(systemName: "lightbulb.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("recommendations".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("recommendations_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("recommendations".localized())
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
