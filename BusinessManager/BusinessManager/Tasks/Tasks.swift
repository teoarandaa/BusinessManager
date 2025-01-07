import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    @Attribute(.unique) var id: String
    var date: Date
    var title: String
    var content: String
    var priority: String
    var isCompleted: Bool
    
    init(date: Date, title: String, content: String, priority: String) {
        self.id = UUID().uuidString
        self.date = date
        self.title = title
        self.content = content
        self.priority = priority
        self.isCompleted = false
    }
}

extension Task: SwiftData.PersistentModel {
}

extension Task: Observation.Observable {
}
