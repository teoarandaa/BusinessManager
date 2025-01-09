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
                        
                        Image(systemName: "chart.xyaxis.line")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
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
                        
                        Image(systemName: "chart.bar.doc.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
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
                        
                        Image(systemName: "chart.dots.scatter")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
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
                        
                        Image(systemName: "chart.bar.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding()
                    }
                }
                .tabItem {
                    Text("yearly_analysis".localized())
                }
                
                // Sixth Page (Volume)
                ScrollView {
                    VStack {
                        Text("volume_chart".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("volume_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding()
                    }
                }
                .tabItem {
                    Text("tasks_chart".localized())
                }
                
                // Seventh Page (Tasks)
                ScrollView {
                    VStack {
                        Text("tasks_chart".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding()
                    }
                }
                .tabItem {
                    Text("tasks_chart".localized())
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
