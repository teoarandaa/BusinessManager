import SwiftUI
import SwiftData

struct GoalDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Bindable var goal: Goal
    @State private var showingDeleteAlert = false
    @State private var currentValueString: String
    
    init(goal: Goal) {
        self.goal = goal
        _currentValueString = State(initialValue: String(goal.currentValue))
    }
    
    var progressValue: Double {
        let progress = Double(goal.currentValue) / Double(goal.targetValue)
        return min(max(progress, 0.0), 1.0)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("\(Int(progressValue * 100))%")
                            .bold()
                    }
                    
                    ProgressView(value: progressValue, total: 1.0)
                        .tint(Color(goal.status == .inProgress ? .yellow : 
                                  goal.status == .completed ? .green : .red))
                    
                    HStack {
                        Text("Current Value")
                        Spacer()
                        TextField("Current", text: $currentValueString)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .onChange(of: currentValueString) {
                                if let value = Int(currentValueString) {
                                    goal.currentValue = value
                                }
                            }
                    }
                }
                
                Section {
                    LabeledContent("Target") {
                        Text("\(goal.targetValue)")
                    }
                    LabeledContent("Type") {
                        Text(goal.type.name)
                    }
                    LabeledContent("Department") {
                        Text(goal.department)
                    }
                    LabeledContent("Deadline") {
                        Text(goal.deadline.formatted(date: .long, time: .omitted))
                    }
                }
                
                if !goal.notes.isEmpty {
                    Section("Notes") {
                        Text(goal.notes)
                    }
                }
                
                if goal.status == .inProgress {
                    Section {
                        Button("Delete Goal", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(goal.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { 
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss() 
                    }
                }
            }
            .alert("Delete Goal", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    context.delete(goal)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this goal?")
            }
        }
    }
} 