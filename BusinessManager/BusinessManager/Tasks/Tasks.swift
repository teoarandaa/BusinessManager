import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    @Attribute(.unique) var id: String
    var date: Date
    var title: String
    var content: String
    var comments: String
    var priority: String
    
    init(date: Date, title: String, content: String, comments: String, priority: String) {
        self.id = UUID().uuidString
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
