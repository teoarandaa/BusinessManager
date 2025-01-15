import SwiftData
import SwiftUI

@Model
class QualityInsight {
    var id: UUID = UUID()
    var date: Date = Date.now
    var title: String = ""
    var insightDescription: String = ""
    var department: String = ""
    var type: InsightType = InsightType.performance
    var isResolved: Bool = false
    @Attribute(.externalStorage) var cloudID: String = UUID().uuidString
    
    enum InsightType: Int, Codable {
        case performance
        case volume
        case delay
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date.now,
        title: String = "",
        description: String = "",
        department: String = "",
        type: InsightType = InsightType.performance,
        isResolved: Bool = false
    ) {
        self.id = id
        self.cloudID = UUID().uuidString
        self.date = date
        self.title = title
        self.insightDescription = description
        self.department = department
        self.type = type
        self.isResolved = isResolved
    }
} 
