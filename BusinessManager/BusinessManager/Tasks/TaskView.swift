import SwiftUI
import SwiftData
import UserNotifications

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
                            TaskRow(task: task, context: context, selectedTask: $taskToEdit)
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
                            TaskRow(task: task, context: context, selectedTask: $taskToEdit)
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
                    .presentationDetents([.height(550)])
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

struct TaskRow: View {
    let task: Task
    let context: ModelContext
    @Binding var selectedTask: Task?
    
    // Función para calcular los días restantes o de retraso
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = Date()
        return calendar.numberOfDaysBetween(from: today, to: task.date)
    }
    
    // Función para determinar el color de la fecha
    private var dateColor: Color {
        if task.isCompleted {
            return .secondary
        }
        
        if daysRemaining < 0 {
            return .red
        } else if daysRemaining <= 2 { // 2 días o menos
            return .yellow
        }
        return .secondary
    }
    
    // Función para obtener el texto de días de retraso
    private var delayText: String? {
        guard daysRemaining < 0 && !task.isCompleted else { return nil }
        let days = abs(daysRemaining)
        return "(\("delay_days".localized()): \(days))"
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                Text(task.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(task.priority)
                    .font(.callout)
                    .padding(10)
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
                        .cornerRadius(10)
                    )
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(task.date, format: .dateTime.day().month().year())
                        .font(.caption)
                        .foregroundStyle(dateColor)
                    
                    if let delayText = delayText {
                        Text(delayText)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTask = task
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                context.delete(task)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                Label("delete".localized(), systemImage: "trash")
            }
            
            Button {
                task.isCompleted.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } label: {
                if task.isCompleted {
                    Label("reactivate".localized(), systemImage: "arrow.uturn.backward")
                } else {
                    Label("complete".localized(), systemImage: "checkmark")
                }
            }
            .tint(task.isCompleted ? .blue : .green)
        }
    }
}

// Extensión de Calendar para calcular días entre fechas
extension Calendar {
    func numberOfDaysBetween(from: Date, to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day ?? 0
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
    
    private func scheduleNotification(for task: Task) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        print("\n📅 Task: \(task.title)")
        print("📆 Due date: \(dateFormatter.string(from: task.date))")
        print("🔔 Scheduling notifications:")
        
        // Notificaciones antes del vencimiento
        let notificationDays = [3, 2, 1, 0]
        
        for days in notificationDays {
            let content = UNMutableNotificationContent()
            
            if days == 0 {
                content.title = "task_due_today_title".localized()
                content.body = String(format: "task_due_today_body".localized(), task.title)
                
                // Obtener las 00:00 del día de vencimiento
                let calendar = Calendar.current
                let notificationDate = calendar.startOfDay(for: task.date)
                
                if notificationDate > Date() {
                    let components = calendar.dateComponents([.year, .month, .day], from: notificationDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    
                    let request = UNNotificationRequest(
                        identifier: "task-\(task.id)-\(days)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Error scheduling notification for \(days) days before: \(error.localizedDescription)")
                        } else {
                            print("✅ Notification scheduled:")
                            print("   • \(days) days before")
                            print("   • Will trigger at: \(dateFormatter.string(from: notificationDate))")
                            print("   • Message: \(content.body)")
                        }
                    }
                }
            } else {
                content.title = String(format: "task_due_in_days_title".localized(), days)
                content.body = String(format: "task_due_in_days_body".localized(), task.title, days)
            }
            
            content.sound = .default
            
            // Calcular la fecha de notificación
            let notificationDate = Calendar.current.date(byAdding: .day, value: -days, to: task.date) ?? task.date
            
            // Solo programar si la fecha no ha pasado
            if notificationDate > Date() {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "task-\(task.id)-\(days)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling notification for \(days) days before: \(error.localizedDescription)")
                    } else {
                        print("✅ Notification scheduled:")
                        print("   • \(days) days before")
                        print("   • Will trigger at: \(dateFormatter.string(from: notificationDate))")
                        print("   • Message: \(content.body)")
                    }
                }
            } else {
                print("⚠️ Skipped notification for \(days) days before - Date already passed")
                print("   • Would have been: \(dateFormatter.string(from: notificationDate))")
            }
        }
        
        // Notificación de retraso (1 hora después de la fecha de vencimiento)
        let delayContent = UNMutableNotificationContent()
        delayContent.title = "task_overdue_title".localized()
        delayContent.body = String(format: "task_overdue_body".localized(), task.title)
        delayContent.sound = .default
        
        let delayDate = Calendar.current.date(byAdding: .hour, value: 1, to: task.date) ?? task.date
        let delayComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: delayDate)
        let delayTrigger = UNCalendarNotificationTrigger(dateMatching: delayComponents, repeats: false)
        
        let delayRequest = UNNotificationRequest(
            identifier: "task-\(task.id)-overdue",
            content: delayContent,
            trigger: delayTrigger
        )
        
        UNUserNotificationCenter.current().add(delayRequest) { error in
            if let error = error {
                print("❌ Error scheduling overdue notification: \(error.localizedDescription)")
            } else {
                print("✅ Overdue notification scheduled:")
                print("   • Will trigger at: \(dateFormatter.string(from: delayDate))")
                print("   • Message: \(delayContent.body)")
            }
        }
        
        print("🔄 Notification setup completed\n")
    }
    
    private func saveTask() {
        let task = Task(
            date: date,
            title: title,
            content: content,
            priority: priority
        )
        
        context.insert(task)
        
        do {
            try context.save()
            scheduleNotification(for: task)  // Programar notificación
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
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("title".localized())
                            .bold()
                    }
                    Spacer()
                    TextField("add_title".localized(), text: $title, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "doc.text")
                    VStack(alignment: .leading) {
                        Text("content".localized())
                            .bold()
                        TextField("add_description".localized(), text: $content, axis: .vertical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4...6)
                    }
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
    
    private func updateNotification(for task: Task) {
        // Primero eliminar todas las notificaciones existentes para esta tarea
        let identifiers = [
            "task-\(task.id)-3",
            "task-\(task.id)-2",
            "task-\(task.id)-1",
            "task-\(task.id)-0",
            "task-\(task.id)-overdue"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        print("\n📅 Task Update: \(task.title)")
        print("📆 New due date: \(dateFormatter.string(from: task.date))")
        print("🔔 Rescheduling notifications:")
        
        // Reprogramar todas las notificaciones
        let notificationDays = [3, 2, 1, 0]
        
        for days in notificationDays {
            let content = UNMutableNotificationContent()
            
            if days == 0 {
                content.title = "task_due_today_title".localized()
                content.body = String(format: "task_due_today_body".localized(), task.title)
                
                // Obtener las 00:00 del día de vencimiento
                let calendar = Calendar.current
                let notificationDate = calendar.startOfDay(for: task.date)
                
                if notificationDate > Date() {
                    let components = calendar.dateComponents([.year, .month, .day], from: notificationDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    
                    let request = UNNotificationRequest(
                        identifier: "task-\(task.id)-\(days)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Error scheduling notification for \(days) days before: \(error.localizedDescription)")
                        } else {
                            print("✅ Notification rescheduled:")
                            print("   • \(days) days before")
                            print("   • Will trigger at: \(dateFormatter.string(from: notificationDate))")
                            print("   • Message: \(content.body)")
                        }
                    }
                }
            } else {
                content.title = String(format: "task_due_in_days_title".localized(), days)
                content.body = String(format: "task_due_in_days_body".localized(), task.title, days)
            }
            
            content.sound = .default
            
            let notificationDate = Calendar.current.date(byAdding: .day, value: -days, to: task.date) ?? task.date
            
            if notificationDate > Date() {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "task-\(task.id)-\(days)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling notification for \(days) days before: \(error.localizedDescription)")
                    } else {
                        print("✅ Notification rescheduled:")
                        print("   • \(days) days before")
                        print("   • Will trigger at: \(dateFormatter.string(from: notificationDate))")
                        print("   • Message: \(content.body)")
                    }
                }
            } else {
                print("⚠️ Skipped notification for \(days) days before - Date already passed")
                print("   • Would have been: \(dateFormatter.string(from: notificationDate))")
            }
        }
        
        // Notificación de retraso
        let delayContent = UNMutableNotificationContent()
        delayContent.title = "task_overdue_title".localized()
        delayContent.body = String(format: "task_overdue_body".localized(), task.title)
        delayContent.sound = .default
        
        let delayDate = Calendar.current.date(byAdding: .hour, value: 1, to: task.date) ?? task.date
        let delayComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: delayDate)
        let delayTrigger = UNCalendarNotificationTrigger(dateMatching: delayComponents, repeats: false)
        
        let delayRequest = UNNotificationRequest(
            identifier: "task-\(task.id)-overdue",
            content: delayContent,
            trigger: delayTrigger
        )
        
        UNUserNotificationCenter.current().add(delayRequest) { error in
            if let error = error {
                print("❌ Error scheduling overdue notification: \(error.localizedDescription)")
            } else {
                print("✅ Overdue notification rescheduled:")
                print("   • Will trigger at: \(dateFormatter.string(from: delayDate))")
                print("   • Message: \(delayContent.body)")
            }
        }
        
        print("🔄 Notification update completed\n")
    }
    
    // Actualizar la función done para incluir la actualización de la notificación
    private func done() {
        updateNotification(for: task)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
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
                    DatePicker("", selection: $task.date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "text.alignleft")
                        Text("title".localized())
                            .bold()
                    }
                    Spacer()
                    TextField("add_title".localized(), text: $task.title, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "doc.text")
                    VStack(alignment: .leading) {
                        Text("content".localized())
                            .bold()
                        TextField("add_description".localized(), text: $task.content, axis: .vertical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4...6)
                    }
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
                        done()
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
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text("expiring_date".localized())
                                .bold()
                        }
                        Spacer()
                        Text(task.date, format: .dateTime.day().month(.abbreviated).year().hour().minute())
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "text.alignleft")
                            Text("title".localized())
                                .bold()
                        }
                        Spacer()
                        Text(task.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("content".localized())
                                .bold()
                        }
                        Text(task.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "flag")
                            Text("priority".localized())
                                .bold()
                        }
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
                        HStack {
                            Image(systemName: "gauge.with.needle")
                            Text("status".localized())
                                .bold()
                        }
                        Spacer()
                        Text(task.isCompleted ? "completed".localized() : "active".localized())
                            .foregroundStyle(task.isCompleted ? .green : .blue)
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
        }
    }
}
