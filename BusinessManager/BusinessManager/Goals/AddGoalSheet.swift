import SwiftUI
import SwiftData

struct AddGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    
    @State private var title = ""
    @State private var targetValue = ""
    @State private var deadline = Date()
    @State private var type: Goal.GoalType = .performance
    @State private var department = ""
    @State private var notes = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal Title", text: $title)
                    TextField("Target Value", text: $targetValue)
                        .keyboardType(.numberPad)
                    DatePicker(
                        "Deadline",
                        selection: $deadline,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section {
                    Picker("Type", selection: $type) {
                        Text("Performance")
                            .tag(Goal.GoalType.performance)
                        Text("Volume")
                            .tag(Goal.GoalType.volume)
                        Text("Tasks")
                            .tag(Goal.GoalType.tasks)
                    }
                    TextField("Department", text: $department)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Goal")
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
                    Button("Add") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || targetValue.isEmpty || department.isEmpty)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveGoal() {
        guard let target = Int(targetValue) else {
            alertMessage = "Please enter a valid target value"
            showAlert = true
            return
        }
        
        if deadline < Date() {
            alertMessage = "Deadline cannot be in the past"
            showAlert = true
            return
        }
        
        let goal = Goal(
            title: title,
            targetValue: target,
            deadline: deadline,
            type: type,
            department: department,
            notes: notes
        )
        
        context.insert(goal)
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            alertMessage = "Failed to save goal: \(error.localizedDescription)"
            showAlert = true
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
} 