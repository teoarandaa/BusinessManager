import SwiftUI

struct PlansView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("coming_soon", systemImage: "sparkles")
            } description: {
                Text("plans_description")
            }
            .navigationTitle("subscription_packages")
        }
    }
}

#Preview {
    PlansView()
}
