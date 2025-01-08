import SwiftUI

struct Recommendation: Identifiable {
    let id = UUID()
    let department: String
    let issue: String
    let suggestions: [String]
    let type: RecommendationType
    
    enum RecommendationType {
        case performance
        case volume
        case taskCompletion
        
        var color: Color {
            switch self {
            case .performance: return .blue
            case .volume: return .orange
            case .taskCompletion: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .performance: return "chart.line.uptrend.xyaxis"
            case .volume: return "chart.bar.fill"
            case .taskCompletion: return "clock.badge.exclamationmark"
            }
        }
    }
} 