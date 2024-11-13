//
//  Reports.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 13/11/24.
//

import Foundation
import SwiftData

@Model
class Report {
    var date: Date
    var departamentName: String
    var performanceMark: Int
    var volumeOfWorkMark: Int
    var numberOfFinishedTasks: Int
    var annotations: String
    
    init(date: Date, departamentName: String, performanceMark: Int, volumeOfWorkMark: Int, numberOfFinishedTasks: Int, annotations: String) {
        self.date = date
        self.departamentName = departamentName
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
