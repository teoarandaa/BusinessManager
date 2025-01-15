import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    var id: String = UUID().uuidString
    var date: Date = Date.now
    var title: String = ""
    var content: String = ""
    var priority: String = ""
    var isCompleted: Bool = false
    @Attribute(.externalStorage) var cloudID: String = UUID().uuidString
    
    init(date: Date, title: String, content: String, priority: String) {
        self.id = UUID().uuidString
        self.cloudID = UUID().uuidString
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
