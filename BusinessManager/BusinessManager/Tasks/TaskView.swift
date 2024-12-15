import SwiftUI
import SwiftData

struct TaskView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @State private var isShowingSettings = false
    @Environment(\.modelContext) var context
    @Query(sort: [SortDescriptor(\Task.date)]) private var tasks: [Task]
    @State private var taskToEdit: Task?
    @State private var searchText = ""
    @State private var sortOption: SortOption = .date
    
    var activeTasks: [Task] {
        sortedTasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        sortedTasks.filter { $0.isCompleted }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case priority = "Priority"
        
        var id: String { self.rawValue }
    }
    
    var sortedTasks: [Task] {
        let filtered = filteredTasks
        switch sortOption {
        case .date:
            return filtered.sorted { $0.date < $1.date }
        case .priority:
            let priorityOrder = ["P1": 0, "P2": 1, "P3": 2]
            return filtered.sorted { 
                (priorityOrder[$0.priority] ?? 0) < (priorityOrder[$1.priority] ?? 0)
            }
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
            List {
                if !activeTasks.isEmpty {
                    Section("Active Tasks") {
                        ForEach(activeTasks) { task in
                            TasksCell(task: task)
                                .onTapGesture {
                                    taskToEdit = task
                                }
                                .swipeActions {
                                    Button {
                                        withAnimation {
                                            task.isCompleted = true
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                        }
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.green)
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                context.delete(activeTasks[index])
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                            }
                        }
                    }
                }
                
                if !completedTasks.isEmpty {
                    Section("Completed Tasks") {
                        ForEach(completedTasks) { task in
                            TasksCell(task: task)
                                .onTapGesture {
                                    taskToEdit = task
                                }
                                .swipeActions {
                                    Button {
                                        withAnimation {
                                            task.isCompleted = false
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                        }
                                    } label: {
                                        Label("Reactivate", systemImage: "arrow.uturn.left.circle.fill")
                                    }
                                    .tint(.blue)
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                context.delete(completedTasks[index])
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                            }
                        }
                    }
                }
            }
            .if(!tasks.isEmpty) { view in
                view.searchable(text: $searchText, prompt: "Search tasks")
                    .searchSuggestions {
                        if searchText.isEmpty {
                            ForEach(tasks.prefix(3)) { task in
                                Label(task.title, systemImage: "magnifyingglass")
                                    .searchCompletion(task.title)
                            }
                        }
                    }
            }
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
                TaskDetailSheet(task: task, context: context)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Information", systemImage: "info.circle") {
                        isShowingItemSheet2 = true
                    }
                    Button("Settings", systemImage: "gear") {
                        isShowingSettings = true
                    }
                }
                if !tasks.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            Picker("Sort by", selection: $sortOption) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button("Add Task", systemImage: "plus") {
                            isShowingItemSheet1 = true
                        }
                    }
                }
            }
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Tasks", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start adding tasks to see your list.")
                    }, actions: {
                        Button("Add Task") { isShowingItemSheet1 = true }
                    })
                    .offset(y: -60)
                } else if !searchText.isEmpty && filteredTasks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
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
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
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
        .contentShape(Rectangle())
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
    
    private func saveTask() {
        let task = Task(
            date: date,
            title: title,
            content: content,
            comments: comments,
            priority: priority
        )
        
        context.insert(task)
        
        do {
            try context.save()
            print("Task saved: \(task.id) - \(task.title)")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Error saving task: \(error)")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
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
                        saveTask()
                    }
                    .disabled(title.isEmpty)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TaskDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task
    let context: ModelContext
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(task.date, format: .dateTime.year().month(.abbreviated).day())
                    }
                    
                    HStack {
                        Text("Title")
                        Spacer()
                        Text(task.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Content")
                        Spacer()
                        Text(task.content)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !task.comments.isEmpty {
                        HStack {
                            Text("Comments")
                            Spacer()
                            Text(task.comments)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    HStack {
                        Text("Priority")
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
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(task.isCompleted ? "Completed" : "Active")
                            .foregroundStyle(task.isCompleted ? .green : .blue)
                    }
                }
                
                Section {
                    Button("Delete Task", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                UpdateTaskSheet(task: task)
            }
            .alert("Delete Task", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    context.delete(task)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
        }
    }
}
