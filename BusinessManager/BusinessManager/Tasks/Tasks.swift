//
//  Tasks.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 14/11/24.
//

import Foundation
import SwiftData

@Model
class Task {
    var date: Date
    var title: String
    var content: String
    var comments: String
    var priority: String
    
    init(date: Date, title: String, content: String, comments: String, priority: String) {
        self.date = date
        self.title = title
        self.content = content
        self.comments = comments
        self.priority = priority
    }
}

extension Task: SwiftData.PersistentModel {
}

extension Task: Observation.Observable {
}
