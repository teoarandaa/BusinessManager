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
    var id: Int { date.hashValue }
    
    init(from report: Report) {
        self.date = report.date
        self.departmentName = report.departmentName
        self.performanceMark = report.performanceMark
        self.volumeOfWorkMark = report.volumeOfWorkMark
        self.numberOfFinishedTasks = report.numberOfFinishedTasks
        self.size = Double(report.numberOfFinishedTasks)
    }
}
