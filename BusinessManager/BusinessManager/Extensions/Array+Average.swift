import Foundation

extension Array where Element == Double {
    var average: Double? {
        guard !isEmpty else { return nil }
        return reduce(0.0, +) / Double(count)
    }
} 