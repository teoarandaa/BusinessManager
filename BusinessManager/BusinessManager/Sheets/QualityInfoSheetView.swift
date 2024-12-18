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
                        
                        Image("quality1") // Necesitarás añadir esta imagen
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
                        Text("Understanding Metrics")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Performance shows the percentage of tasks completed on time. Volume of Work indicates the ratio of finished tasks to total tasks. Task Completion Rate measures overall efficiency by comparing completed tasks to created tasks. Trends help identify patterns and areas for improvement.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("quality2") // Necesitarás añadir esta imagen
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Metrics")
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