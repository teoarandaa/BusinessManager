import SwiftUI

struct TasksInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("tasks_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("tasks1")
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
                        Text("how_create_tasks".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_creation_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("tasks2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("managing_tasks".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Text("sort_tasks".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("sort_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("tasks3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("sort".localized())
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("add_task".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("add_task_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        Image("tasks4")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                .tabItem {
                    Text("add_task".localized())
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
    TasksInfoSheetView()
}
