import SwiftData
import SwiftUI

@Model
class QualityInsight {
    var id: UUID
    var date: Date
    var title: String
    var insightDescription: String
    var department: String
    var type: InsightType
    var isResolved: Bool
    
    enum InsightType: Int, Codable {
        case performance
        case volume
        case delay
    }
    
    init(
        id: UUID = UUID(),
        date: Date = .now,
        title: String,
        description: String,
        department: String,
        type: InsightType,
        isResolved: Bool = false
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.insightDescription = description
        self.department = department
        self.type = type
        self.isResolved = isResolved
    }
} 