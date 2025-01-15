import SwiftData
import SwiftUI

@Model
class QualityMetric {
    var id: UUID = UUID()
    var date: Date = Date.now
    var name: String = ""
    var value: Double = 0.0
    var target: Double = 0.0
    var trend: MetricTrend = MetricTrend.stable
    var impact: ImpactLevel = ImpactLevel.medium
    @Relationship(inverse: \Report.metrics) var report: Report?
    @Attribute(.externalStorage) var cloudID: String = UUID().uuidString
    
    enum MetricTrend: Int, Codable, CaseIterable {
        case improving = 0
        case stable = 1
        case declining = 2
    }
    
    enum ImpactLevel: Int, Codable, CaseIterable {
        case critical = 0
        case high = 1
        case medium = 2
        case low = 3
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date.now,
        name: String,
        value: Double,
        target: Double,
        trend: MetricTrend,
        impact: ImpactLevel,
        report: Report? = nil
    ) {
        self.id = id
        self.cloudID = UUID().uuidString
        self.date = date
        self.name = name
        self.value = value
        self.target = target
        self.trend = trend
        self.impact = impact
        self.report = report
    }
}
