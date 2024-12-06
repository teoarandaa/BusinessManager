import SwiftUI
import SwiftData

struct TaskView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @Environment(\.modelContext) var context
    @Query(sort: \Task.date) var tasks: [Task]
    @State private var taskToEdit: Task?
    @State private var showingBottomSheet: Bool = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .date

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case priority = "Priority"
        
        var id: String { self.rawValue }
    }
    
    var sortedTasks: [Task] {
        switch sortOption {
        case .date:
            return filteredTasks.sorted(by: { $0.date < $1.date })
        case .priority:
            return filteredTasks.sorted(by: { $0.priority < $1.priority })
        }
    }
    
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())


                List {
                    ForEach(sortedTasks) { task in
                        TasksCell(task: task)
                            .onTapGesture {
                                taskToEdit = task
                            }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(sortedTasks[index])
                        }
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Tasks")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet1) {
                    AddTaskSheet()
                }
                .sheet(isPresented: $isShowingItemSheet2) {
                    TasksInfoSheetView()
                        .presentationDetents([.height(700)])
                }
                .sheet(item: $taskToEdit) { task in
                    UpdateTaskSheet(task: task)
                }
                .toolbar {
                    if !filteredTasks.isEmpty {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button("Add Task", systemImage: "plus") {
                                isShowingItemSheet1 = true
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("Information", systemImage: "info.circle") {
                            isShowingItemSheet2 = true
                        }
                    }
                }
                .overlay {
                    if filteredTasks.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No Tasks", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Start adding tasks to see your list.")
                        }, actions: {
                            Button("Add Task") { isShowingItemSheet1 = true }
                        })
                        .offset(y: -60)
                    }
                }
            }
        }
    }
}

#Preview {
    TaskView()
}

struct TasksCell: View {
    let task: Task
    
    var body: some View {
        HStack {
            Text(task.date, format: .dateTime.year().month(.abbreviated).day())
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(task.title)
                .bold()
            Spacer()
            Text(task.priority)
                .padding(8)
                .foregroundStyle(
                    task.priority == "P1" ? Color.red :
                    task.priority == "P2" ? Color.yellow :
                    Color.green
                )
                .background(
                    (task.priority == "P1" ? Color.red :
                    task.priority == "P2" ? Color.yellow :
                    Color.green)
                    .opacity(0.2)
                    .cornerRadius(8)
                )
                .bold()
        }
    }
}

struct AddTaskSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var comments: String = ""
    @State private var priority: String = "P3"
    
    let priorityOptions = ["P3", "P2", "P1"]
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Expiring date")
                            .bold()
                    }
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("Title")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $title, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Content")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $content, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.bubble")
                        Text("Comments")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $comments, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "flag")
                        Text("Priority")
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $priority) {
                        ForEach(priorityOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 120)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { 
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss() 
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let task = Task(date: date, title: title, content: content, comments: comments, priority: priority)
                        context.insert(task)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UpdateTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: Task
    
    let priorityOptions = ["P3", "P2", "P1"]
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Expiring date")
                            .bold()
                    }
                    Spacer()
                    DatePicker("", selection: $task.date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("Title")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $task.title, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Content")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $task.content, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.bubble")
                        Text("Comments")
                            .bold()
                    }
                    Spacer()
                    TextField("", text: $task.comments, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "flag")
                        Text("Priority")
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $task.priority) {
                        ForEach(priorityOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 120)
                }
            }
            .navigationTitle("Update Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
