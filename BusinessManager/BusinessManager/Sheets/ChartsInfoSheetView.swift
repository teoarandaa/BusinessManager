import SwiftUI

struct ChartsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("analytics_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("analytics_description".localized())
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
                        Image(systemName: "plus.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("how_create_charts".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("charts_generation".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("creating_reports".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Image(systemName: "chart.pie.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("chart_types".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("chart_types_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("chart_types".localized())
                }
                
                // Fourth Page
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
                        
                        Text("yearly_analysis".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("yearly_analysis_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("yearly_analysis".localized())
                }
                
                // Sixth Page (Volume)
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
                        
                        Text("volume_chart".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("volume_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("tasks_chart".localized())
                }
                
                // Seventh Page (Tasks)
                ScrollView {
                    VStack {
                        Image(systemName: "checklist")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("tasks_chart".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
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
