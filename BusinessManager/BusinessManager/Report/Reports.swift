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
        let baseNumber = totalTasksCreated == 0 ? tasksCompletedWithoutDelay : totalTasksCreated
        return Int((Double(tasksCompletedWithoutDelay) / Double(baseNumber)) * 100)
    }
    
    var volumeOfWorkMark: Int {
        let baseNumber = totalTasksCreated == 0 ? numberOfFinishedTasks : totalTasksCreated
        return Int((Double(numberOfFinishedTasks) / Double(baseNumber)) * 100)
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
