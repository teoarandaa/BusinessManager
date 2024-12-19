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
                        Text("Sort Tasks")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The Sort functionality organizes your tasks effectively. Sort by date for a chronological view of deadlines, or by priority to focus on critical tasks first. This flexibility helps you manage your workflow according to your current needs.")
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
                    Text("Sort")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Add Task")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Creating a new task is an intuitive process where you can specify deadlines, set priorities, and add detailed descriptions. Additional comments provide context and improve task tracking, ensuring clear communication throughout the process.")
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
                    Text("Add Task")
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
