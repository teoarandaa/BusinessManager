import SwiftUI

struct GoalsInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // Primera página
                ScrollView {
                    VStack {
                        Text("Goals Overview")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Goals help you monitor progress and achieve specific targets within your business. By categorizing them by department and status, you can maintain clarity, prioritize tasks, and ensure they align with your business objectives. This approach simplifies tracking and enhances focus, helping your team work more effectively towards achieving their goals.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("goals1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Overview")
                }
                
                // Segunda página
                ScrollView {
                    VStack {
                        Text("How to Set Goals")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Define clear, measurable goals for each department to provide direction and focus. Regularly track their progress, identify challenges, and adjust strategies as needed to stay on course. This approach ensures alignment with business objectives and fosters accountability, helping your team achieve consistent success.")
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("goals2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("Setting Goals")
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
    GoalsInfoSheetView()
} 
