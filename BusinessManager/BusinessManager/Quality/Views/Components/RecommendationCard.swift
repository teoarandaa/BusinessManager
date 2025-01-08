import SwiftUI

struct RecommendationCard: View {
    let recommendation: Recommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text(recommendation.department)
                        .font(.headline)
                } icon: {
                    Image(systemName: recommendation.type.icon)
                        .foregroundStyle(.accent)
                }
            }
            
            Text(recommendation.issue)
                .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("suggested_actions".localized())
                    .font(.subheadline)
                    .bold()
                
                ForEach(recommendation.suggestions, id: \.self) { suggestion in
                    Label(suggestion, systemImage: "arrow.right.circle")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 