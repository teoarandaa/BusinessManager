//
//  ChartData.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 17/11/24.
//

import Foundation
import SwiftData

struct ChartData: Identifiable, Equatable {
    let date: Date
    let departmentName: String
    let performanceMark: Int
    let volumeOfWorkMark: Int
    let numberOfFinishedTasks: Int
    var size: Double
    var id: UUID = UUID()
    
    init(from report: Report) {
        self.date = report.date
        self.departmentName = report.departmentName
        self.performanceMark = report.performanceMark
        self.volumeOfWorkMark = report.volumeOfWorkMark
        self.numberOfFinishedTasks = report.numberOfFinishedTasks
        self.size = Double(report.numberOfFinishedTasks)
    }
    
    init(
        date: Date,
        departmentName: String,
        performanceMark: Int,
        volumeOfWorkMark: Int,
        numberOfFinishedTasks: Int
    ) {
        self.date = date
        self.departmentName = departmentName
        self.performanceMark = performanceMark
        self.volumeOfWorkMark = volumeOfWorkMark
        self.numberOfFinishedTasks = numberOfFinishedTasks
        self.size = Double(numberOfFinishedTasks)
    }
}
