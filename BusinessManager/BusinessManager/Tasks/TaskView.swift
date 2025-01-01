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
        case date = "date"
        case priority = "priority"
        
        var id: String { self.rawValue }
        
        var localizedName: String {
            rawValue.localized()
        }
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
                    Section("active_tasks".localized()) {
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
                                        Label("complete".localized(), systemImage: "checkmark.circle.fill")
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
                    Section("completed_tasks".localized()) {
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
                                        Label("reactivate".localized(), systemImage: "arrow.uturn.left.circle.fill")
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
                view.searchable(text: $searchText, prompt: "search_tasks".localized())
                    .searchSuggestions {
                        if searchText.isEmpty {
                            ForEach(tasks.prefix(3)) { task in
                                Label(task.title, systemImage: "magnifyingglass")
                                    .searchCompletion(task.title)
                            }
                        }
                    }
            }
            .navigationTitle("tasks".localized())
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
                    Button("settings".localized(), systemImage: "gear") {
                        isShowingSettings = true
                    }
                    Button("information".localized(), systemImage: "info.circle") {
                        isShowingItemSheet2 = true
                    }
                }
                if !tasks.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            Picker("sort_by".localized(), selection: $sortOption) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.localizedName).tag(option)
                                }
                            }
                        } label: {
                            Label("sort".localized(), systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button("add_task".localized(), systemImage: "plus") {
                            isShowingItemSheet1 = true
                        }
                    }
                }
            }
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView(label: {
                        Label("no_tasks".localized(), systemImage: "list.bullet.clipboard")
                    }, description: {
                        Text("no_tasks_description".localized())
                    }, actions: {
                        Button {
                            isShowingItemSheet1 = true
                        } label: {
                            Label("add_task".localized(), systemImage: "plus")
                        }
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
    
    var dateColor: Color {
        let calendar = Calendar.current
        let today = Date()
        let daysUntilDue = calendar.dateComponents([.day], from: today, to: task.date).day ?? 0
        
        if task.isCompleted {
            return .secondary
        } else if task.date < today {
            return .red
        } else if daysUntilDue <= 1 {
            return .red
        } else if daysUntilDue <= 3 {
            return .orange
        } else if daysUntilDue <= 7 {
            return .yellow
        } else {
            return .primary
        }
    }
    
    var daysOverdue: Int? {
        let calendar = Calendar.current
        let today = Date()
        if task.date < today && !task.isCompleted {
            let days = calendar.dateComponents([.day], from: task.date, to: today).day ?? 0
            return days
        }
        return nil
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(task.date, format: .dateTime.year().month(.abbreviated).day())
                    .foregroundStyle(dateColor)
                if let overdue = daysOverdue {
                    Text(String(format: "days_overdue".localized(), overdue))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .frame(width: 150, alignment: .leading)
            
            Spacer()
            Text(task.title)
                .bold()
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
            Spacer()
            Text(task.priority)
                .padding(4)
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
                    .cornerRadius(6)
                )
                .bold()
        }
        .padding(.vertical, 4)
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
                        Text("expiring_date".localized())
                            .bold()
                    }
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .fixedSize()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("title".localized())
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
                        Text("content".localized())
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
                        Text("comments".localized())
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
                        Text("priority".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $priority) {
                        ForEach(priorityOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 120)
                    .padding(.trailing, -8)
                }
            }
            .navigationTitle("new_task".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("cancel".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("save".localized()) {
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
                        Text("expiring_date".localized())
                            .bold()
                    }
                    Spacer()
                    DatePicker("", selection: $task.date, displayedComponents: .date)
                        .labelsHidden()
                        .fixedSize()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("title".localized())
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
                        Text("content".localized())
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
                        Text("comments".localized())
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
                        Text("priority".localized())
                            .bold()
                    }
                    Spacer()
                    Picker("", selection: $task.priority) {
                        ForEach(priorityOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 120)
                    .padding(.trailing, -8)
                }
            }
            .navigationTitle("update_task".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
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
                        Text("date".localized())
                        Spacer()
                        Text(task.date, format: .dateTime.year().month(.abbreviated).day())
                    }
                    
                    HStack {
                        Text("title".localized())
                        Spacer()
                        Text(task.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("content".localized())
                        Spacer()
                        Text(task.content)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !task.comments.isEmpty {
                        HStack {
                            Text("comments".localized())
                            Spacer()
                            Text(task.comments)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    HStack {
                        Text("priority".localized())
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
                        Text("status".localized())
                        Spacer()
                        Text(task.isCompleted ? "completed".localized() : "active".localized())
                            .foregroundStyle(task.isCompleted ? .green : .blue)
                    }
                }
                
                Section {
                    Button("delete_task".localized(), role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("task_details".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("edit".localized()) {
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                UpdateTaskSheet(task: task)
            }
            .alert("delete_task".localized(), isPresented: $showingDeleteAlert) {
                Button("cancel".localized(), role: .cancel) { }
                Button("delete".localized(), role: .destructive) {
                    context.delete(task)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    dismiss()
                }
            } message: {
                Text("delete_task_confirmation".localized())
            }
        }
    }
}
