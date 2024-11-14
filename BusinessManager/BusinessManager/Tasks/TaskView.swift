//
//  TaskView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 14/11/24.
//

//
//  ReportsView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @Environment(\.modelContext) var context
    @Query(sort: \Task.date) var tasks: [Task]
    @State private var taskToEdit: Task?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    TasksCell(task: task)
                        .onTapGesture {
                            taskToEdit = task
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(tasks[index])
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet1) { AddTaskSheet() }
            .sheet(isPresented: $isShowingItemSheet2) { TasksInfoSheet() }
            .sheet(item: $taskToEdit) { task in
                UpdateTaskSheet(task: task)
            }
            .toolbar {
                if !tasks.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Add Task", systemImage: "plus") {
                            isShowingItemSheet1 = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Add Task", systemImage: "info.circle") {
                        isShowingItemSheet2 = true
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
                    task.priority == "High" ? Color.red :
                    task.priority == "Medium" ? Color.yellow :
                    Color.green
                )
                .background(
                    (task.priority == "High" ? Color.red :
                    task.priority == "Medium" ? Color.yellow :
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
    @State private var priority: String = "Low"
    
    let priorityOptions = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Title", text: $title, axis: .vertical)
                TextField("Content", text: $content, axis: .vertical)
                TextField("Comments", text: $comments, axis: .vertical)
                Picker("Priority", selection: $priority) {
                    ForEach(priorityOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let task = Task(date: date, title: title, content: content, comments: comments, priority: priority)
                        context.insert(task)
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
    
    let priorityOptions = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $task.date, displayedComponents: .date)
                TextField("Title", text: $task.title, axis: .vertical)
                TextField("Content", text: $task.content, axis: .vertical)
                TextField("Comments", text: $task.comments, axis: .vertical)
                Picker("Priority", selection: $task.priority) {
                    ForEach(priorityOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
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

struct TasksInfoSheet: View {
    var body: some View {
        Text("Information sheet")
    }
}
