import SwiftUI

struct TasksInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Text("Tasks Overview")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Tasks help you organize, prioritize, and track your work efficiently. With a clear structure and real-time updates, you can manage deadlines, monitor progress, and keep your workflow optimized, all in one place.")
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
                    Text("Overview")
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Text("How to Create Tasks")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Tasks are created with the following information: expiring date to set deadlines, title for the task name, content for task details, comments for additional notes, and priority to indicate urgency. This data ensures tasks are well-organized and managed effectively.")
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
                    Text("Managing Tasks")
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
                    Button("Ok") {
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
