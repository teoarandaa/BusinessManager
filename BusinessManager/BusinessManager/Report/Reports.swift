import Foundation
import SwiftData
import Observation

@Model
class Report {
    var id: UUID = UUID()
    var date: Date = Date.now
    var departmentName: String = ""
    var totalTasksCreated: Int = 0
    var tasksCompletedWithoutDelay: Int = 0
    var numberOfFinishedTasks: Int = 0
    var annotations: String = ""
    var performanceMark: Int = 0
    var volumeOfWorkMark: Int = 0
    @Relationship(deleteRule: .cascade) var metrics: [QualityMetric]?
    @Attribute(.externalStorage) var cloudID: String = UUID().uuidString
    
    init(
        date: Date = Date.now,
        departmentName: String,
        totalTasksCreated: Int,
        tasksCompletedWithoutDelay: Int,
        numberOfFinishedTasks: Int,
        annotations: String,
        performanceMark: Int = 0,
        volumeOfWorkMark: Int = 0
    ) {
        self.id = UUID()
        self.cloudID = UUID().uuidString
        self.date = date
        self.departmentName = departmentName
        self.totalTasksCreated = totalTasksCreated
        self.tasksCompletedWithoutDelay = tasksCompletedWithoutDelay
        self.numberOfFinishedTasks = numberOfFinishedTasks
        self.annotations = annotations
        self.performanceMark = performanceMark
        self.volumeOfWorkMark = volumeOfWorkMark
        self.metrics = []
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
        let totalTasksCreated = reports.reduce(into: 0) { $0 += $1.totalTasksCreated }
        let tasksCompletedWithoutDelay = reports.reduce(into: 0) { $0 += $1.tasksCompletedWithoutDelay }
        let numberOfFinishedTasks = reports.reduce(into: 0) { $0 += $1.numberOfFinishedTasks }
        
        let annotations = reports
            .map { $0.annotations }
            .filter { !$0.isEmpty }
            .joined(separator: " | ")
        
        let totalPerformance = reports.reduce(into: 0) { $0 += $1.performanceMark }
        let totalVolumeOfWork = reports.reduce(into: 0) { $0 += $1.volumeOfWorkMark }
        
        let avgPerformance = reports.isEmpty ? 0 : totalPerformance / reports.count
        let avgVolumeOfWork = reports.isEmpty ? 0 : totalVolumeOfWork / reports.count
        
        return DailyReportSummary(
            date: reports.first?.date ?? .now,
            departmentName: reports.first?.departmentName ?? "",
            totalTasksCreated: totalTasksCreated,
            tasksCompletedWithoutDelay: tasksCompletedWithoutDelay,
            numberOfFinishedTasks: numberOfFinishedTasks,
            annotations: annotations,
            performanceMark: avgPerformance,
            volumeOfWorkMark: avgVolumeOfWork
        )
    }
}
