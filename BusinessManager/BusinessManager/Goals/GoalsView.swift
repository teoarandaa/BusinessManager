import SwiftUI
import SwiftData
import Charts

struct GoalsView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Goal.deadline) var goals: [Goal]
    @State private var showingAddGoal = false
    @State private var selectedDepartment: String?
    
    var activeGoals: [Goal] { goals.filter { $0.status == .inProgress } }
    var completedGoals: [Goal] { goals.filter { $0.status == .completed } }
    var failedGoals: [Goal] { goals.filter { $0.status == .failed } }
    
    var body: some View {
        NavigationStack {
            List {
                if !goals.isEmpty {
                    GoalsOverviewSection(goals: goals)
                    
                    GoalsByDepartmentSection(goals: goals, selectedDepartment: $selectedDepartment)
                    
                    Section("Active Goals") {
                        if activeGoals.isEmpty {
                            Text("No active goals")
                                .foregroundStyle(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(activeGoals) { goal in
                                GoalCell(goal: goal)
                            }
                        }
                    }
                    
                    Section("Completed Goals") {
                        if completedGoals.isEmpty {
                            Text("No completed goals yet")
                                .foregroundStyle(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(completedGoals) { goal in
                                GoalCell(goal: goal)
                            }
                        }
                    }
                    
                    if !failedGoals.isEmpty {
                        Section("Failed Goals") {
                            ForEach(failedGoals) { goal in
                                GoalCell(goal: goal)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(label: {
                        Label("No Goals", systemImage: "target")
                    }, description: {
                        Text("Start by adding goals for your departments")
                    }, actions: {
                        Button("Add Goal") { showingAddGoal = true }
                    })
                }
            }
            .navigationTitle("Goals & Metrics")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Goal", systemImage: "plus") {
                        showingAddGoal = true
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalSheet()
            }
        }
    }
}

struct GoalsOverviewSection: View {
    let goals: [Goal]
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                HStack {
                    MetricCard(
                        title: "Active Goals",
                        value: goals.filter { $0.status == .inProgress }.count,
                        icon: "target",
                        color: .blue
                    )
                    
                    MetricCard(
                        title: "Completed",
                        value: goals.filter { $0.status == .completed }.count,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
                
                Chart {
                    ForEach(goals.filter { $0.status == .inProgress }) { goal in
                        BarMark(
                            x: .value("Goal", goal.title),
                            y: .value("Progress", goal.progress * 100)
                        )
                        .foregroundStyle(by: .value("Type", goal.type.rawValue))
                    }
                }
                .frame(height: 200)
                .chartXAxis(.visible)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
            .padding(.vertical)
        }
    }
}

struct GoalsByDepartmentSection: View {
    let goals: [Goal]
    @Binding var selectedDepartment: String?
    
    var departments: [String] {
        Array(Set(goals.map { $0.department })).sorted()
    }
    
    var body: some View {
        Section("By Department") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(departments, id: \.self) { department in
                        DepartmentCard(
                            department: department,
                            activeGoals: goals.filter { $0.department == department && $0.status == .inProgress }.count,
                            isSelected: selectedDepartment == department
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedDepartment = selectedDepartment == department ? nil : department
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct GoalCell: View {
    let goal: Goal
    @Environment(\.modelContext) var context
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundStyle(.accent)
                Text(goal.title)
                    .font(.headline)
                Spacer()
                Text(goal.department)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: goal.progress)
                .tint(Color(goal.status == .inProgress ? .yellow : 
                          goal.status == .completed ? .green : .red))
            
            HStack {
                Text("\(goal.currentValue)/\(goal.targetValue)\(goal.type.unit)")
                    .font(.caption)
                Spacer()
                Text(goal.deadline, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            GoalDetailSheet(goal: goal)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text("\(value)")
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct DepartmentCard: View {
    let department: String
    let activeGoals: Int
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(department)
                .font(.headline)
            Text("\(activeGoals) active")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
} 