import Foundation
import SwiftData
import Observation

@Model
class Report {
    @Attribute(.unique) var id: UUID
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
        self.id = UUID()
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

struct DailyReportSummary {
    var date: Date
    var departmentName: String
    var totalTasksCreated: Int
    var tasksCompletedWithoutDelay: Int
    var numberOfFinishedTasks: Int
    var annotations: String
    var performanceMark: Int
    var volumeOfWorkMark: Int
    
    static func fromReports(_ reports: [Report]) -> DailyReportSummary {
        let totalTasksCreated = reports.reduce(0) { $0 + $1.totalTasksCreated }
        let tasksCompletedWithoutDelay = reports.reduce(0) { $0 + $1.tasksCompletedWithoutDelay }
        let numberOfFinishedTasks = reports.reduce(0) { $0 + $1.numberOfFinishedTasks }
        
        // Filtrar anotaciones vacías antes de unirlas
        let annotations = reports
            .map { $0.annotations }
            .filter { !$0.isEmpty }
            .joined(separator: " | ")
        
        // Calculate averages
        let avgPerformance = reports.reduce(0) { $0 + $1.performanceMark } / reports.count
        let avgVolumeOfWork = reports.reduce(0) { $0 + $1.volumeOfWorkMark } / reports.count
        
        return DailyReportSummary(
            date: reports[0].date,
            departmentName: reports[0].departmentName,
            totalTasksCreated: totalTasksCreated,
            tasksCompletedWithoutDelay: tasksCompletedWithoutDelay,
            numberOfFinishedTasks: numberOfFinishedTasks,
            annotations: annotations,
            performanceMark: avgPerformance,
            volumeOfWorkMark: avgVolumeOfWork
        )
    }
}
