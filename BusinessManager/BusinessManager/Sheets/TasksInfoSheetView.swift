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
                        Text("Task Controls")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("The plus button creates new tasks. Use the calendar to set due dates and the priority selector to mark task urgency. The department picker assigns tasks to specific teams.")
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
                    Text("Controls")
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Text("Task Actions")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Mark tasks as complete using the checkmark button. The edit button modifies task details, while the delete button removes tasks. Use filters to sort tasks by status, priority, or department.")
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
                    Text("Actions")
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
