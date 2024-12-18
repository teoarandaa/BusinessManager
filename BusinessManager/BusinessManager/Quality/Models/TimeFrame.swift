import SwiftUI

enum TimeFrame: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    
    var systemImage: String {
        switch self {
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .quarter: return "calendar.badge.plus"
        case .year: return "calendar.badge.exclamationmark"
        }
    }
} 