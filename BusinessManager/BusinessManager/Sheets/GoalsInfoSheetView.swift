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
                        
                        Text("Goals help you track progress and achieve targets. Organize them by department and status to ensure alignment with your business objectives.")
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
                        
                        Text("Define clear, measurable goals for each department. Track their progress and adjust strategies to ensure success.")
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