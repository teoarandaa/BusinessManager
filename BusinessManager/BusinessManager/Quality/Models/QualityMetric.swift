import SwiftData
import SwiftUI

@Model
class QualityMetric {
    var id: UUID
    var date: Date
    var name: String
    var value: Double
    var target: Double
    var trend: MetricTrend
    var impact: ImpactLevel
    @Relationship(deleteRule: .cascade) var report: Report?
    
    enum MetricTrend: Int, Codable {
        case improving
        case stable
        case declining
    }
    
    enum ImpactLevel: Int, Codable {
        case critical
        case high
        case medium
        case low
    }
    
    init(
        id: UUID = UUID(),
        date: Date = .now,
        name: String,
        value: Double,
        target: Double,
        trend: MetricTrend,
        impact: ImpactLevel,
        report: Report? = nil
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.value = value
        self.target = target
        self.trend = trend
        self.impact = impact
        self.report = report
    }
}