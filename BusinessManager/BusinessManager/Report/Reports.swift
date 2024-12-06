import Foundation
import SwiftData

@Model
class Report {
    var date: Date
    var departmentName: String
    var performanceMark: Int
    var volumeOfWorkMark: Int
    var numberOfFinishedTasks: Int
    var annotations: String
    
    init(date: Date, departmentName: String, performanceMark: Int, volumeOfWorkMark: Int, numberOfFinishedTasks: Int, annotations: String) {
        self.date = date
        self.departmentName = departmentName
        self.performanceMark = performanceMark
        self.volumeOfWorkMark = volumeOfWorkMark
        self.numberOfFinishedTasks = numberOfFinishedTasks
        self.annotations = annotations
    }
}

extension Report: SwiftData.PersistentModel {
}

extension Report: Observation.Observable {
}
