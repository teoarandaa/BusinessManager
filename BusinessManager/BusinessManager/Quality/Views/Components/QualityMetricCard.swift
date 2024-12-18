import SwiftUI

struct QualityMetricCard: View {
    let metric: QualityMetric
    
    private var trendColor: Color {
        switch metric.trend {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .red
        }
    }
    
    private var trendIcon: String {
        switch metric.trend {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "equal.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    private var trendText: String {
        switch metric.trend {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
    
    private var progressColor: Color {
        let percentage = metric.value / metric.target
        if percentage >= 1 { return .green }
        if percentage >= 0.8 { return .yellow }
        return .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(metric.name)
                    .font(.headline)
                Spacer()
                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(metric.value))")
                    .font(.title)
                    .bold()
                Text("%")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Gauge(value: metric.value, in: 0...metric.target) {
                EmptyView()
            }
            .tint(progressColor)
            
            HStack {
                Text("Target: \(Int(metric.target))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(trendText, systemImage: trendIcon)
                    .font(.caption)
                    .foregroundStyle(trendColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    QualityMetricCard(metric: QualityMetric(
        date: .now,
        name: "Performance",
        value: 85,
        target: 90,
        trend: .improving,
        impact: .high
    ))
    .padding()
} 