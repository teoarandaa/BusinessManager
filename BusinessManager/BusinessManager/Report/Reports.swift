import Foundation
import SwiftData
import Observation

@Model
class Report {
    var date: Date
    var departmentName: String
    var totalTasksCreated: Int
    var tasksCompletedWithoutDelay: Int
    var numberOfFinishedTasks: Int
    var annotations: String
    
    // Propiedades calculadas
    var performanceMark: Int {
        guard totalTasksCreated > 0 else { return 0 }
        let performance = Double(tasksCompletedWithoutDelay) / Double(totalTasksCreated)
        return Int(performance * 100)
    }
    
    var volumeOfWorkMark: Int {
        guard totalTasksCreated > 0 else { return 0 }
        let volume = Double(numberOfFinishedTasks) / Double(totalTasksCreated)
        return Int(volume * 100)
    }
    
    init(
        date: Date = .now,
        departmentName: String,
        totalTasksCreated: Int,
        tasksCompletedWithoutDelay: Int,
        numberOfFinishedTasks: Int,
        annotations: String
    ) {
        self.date = date
        self.departmentName = departmentName
        self.totalTasksCreated = totalTasksCreated
        self.tasksCompletedWithoutDelay = tasksCompletedWithoutDelay
        self.numberOfFinishedTasks = numberOfFinishedTasks
        self.annotations = annotations
    }
}

extension Report: SwiftData.PersistentModel {
}

extension Report: Observation.Observable {
}
