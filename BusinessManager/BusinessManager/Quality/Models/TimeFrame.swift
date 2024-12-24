import SwiftUI

enum TimeFrame: String, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    
    var localizedString: String {
        rawValue.localized()
    }
    
    var systemImage: String {
        switch self {
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .quarter: return "calendar.badge.plus"
        case .year: return "calendar.badge.exclamationmark"
        }
    }
} 
