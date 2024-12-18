import SwiftUI

struct QualityInsightCard: View {
    @Environment(\.modelContext) var context
    let insight: QualityInsight
    
    private var typeColor: Color {
        switch insight.type {
        case .performance: return .blue
        case .volume: return .orange
        case .delay: return .red
        }
    }
    
    private var typeIcon: String {
        switch insight.type {
        case .performance: return "chart.line.uptrend.xyaxis"
        case .volume: return "chart.bar.fill"
        case .delay: return "clock.badge.exclamationmark"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text(insight.title)
                        .font(.headline)
                } icon: {
                    Image(systemName: typeIcon)
                        .foregroundStyle(typeColor)
                }
                
                Spacer()
                
                Text(insight.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(insight.insightDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Label(insight.department, systemImage: "building.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    insight.isResolved.toggle()
                    try? context.save()
                } label: {
                    Label("Mark as Resolved", systemImage: "checkmark.circle")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
} 