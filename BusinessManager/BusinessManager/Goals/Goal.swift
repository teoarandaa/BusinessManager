import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var targetValue: Int
    var currentValue: Int
    var deadline: Date
    var type: GoalType
    var department: String
    var notes: String
    var createdAt: Date
    
    enum GoalType: Int, Codable {
        case performance = 0
        case volume = 1
        case tasks = 2
        
        var icon: String {
            switch self {
            case .performance: return "chart.line.uptrend.xyaxis"
            case .volume: return "chart.bar.fill"
            case .tasks: return "checklist"
            }
        }
        
        var unit: String {
            switch self {
            case .performance, .volume: return "%"
            case .tasks: return "tasks"
            }
        }
        
        var name: String {
            switch self {
            case .performance: return "Performance"
            case .volume: return "Volume"
            case .tasks: return "Tasks"
            }
        }
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0.0 }
        let calculatedProgress = Double(currentValue) / Double(targetValue)
        return min(max(calculatedProgress, 0.0), 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var status: GoalStatus {
        if Date() > deadline {
            return progress >= 1.0 ? .completed : .failed
        }
        if progress >= 1.0 {
            return .completed
        }
        return .inProgress
    }
    
    enum GoalStatus {
        case inProgress, completed, failed
        
        var color: String {
            switch self {
            case .inProgress: return "yellow"
            case .completed: return "green"
            case .failed: return "red"
            }
        }
    }
    
    var isAccumulative: Bool {
        type == .tasks
    }
    
    func updateProgress(with value: Int) {
        if isAccumulative {
            currentValue += value
        } else {
            currentValue = max(currentValue, value)
        }
    }
    
    init(title: String, targetValue: Int, currentValue: Int = 0, deadline: Date, type: GoalType, department: String, notes: String = "") {
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.deadline = deadline
        self.type = type
        self.department = department
        self.notes = notes
        self.createdAt = Date()
    }
} 