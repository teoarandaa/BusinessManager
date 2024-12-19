import SwiftUI

// MARK: - Constants to save information
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQView: View {
    @State private var expandedItem: UUID?
    // MARK: - FAQs content
    let faqItems: [FAQItem] = [
        FAQItem(
            question: "what_is_business_manager".localized(),
            answer: "business_manager_description".localized()
        ),
        FAQItem(
            question: "is_business_manager_free".localized(),
            answer: "business_manager_pricing".localized()
        ),
        FAQItem(
            question: "how_often_new_features".localized(),
            answer: "new_features_frequency".localized()
        ),
        FAQItem(
            question: "frequent_updates".localized(),
            answer: "updates_frequency".localized()
        ),
        FAQItem(
            question: "enable_push_notifications".localized(),
            answer: "push_notifications_instructions".localized()
        ),
        FAQItem(
            question: "multiple_languages".localized(),
            answer: "available_languages".localized()
        ),
        FAQItem(
            question: "payment_methods".localized(),
            answer: "accepted_payments".localized()
        ),
        FAQItem(
            question: "privacy_policy_location".localized(),
            answer: "find_privacy_policy".localized()
        ),
        FAQItem(
            question: "technical_issues".localized(),
            answer: "technical_support".localized()
        ),
        FAQItem(
            question: "contact_support".localized(),
            answer: "support_contact".localized()
        )
    ]
    
    // MARK: - Expanding buttons to show answers when tapped
    var body: some View {
        List(faqItems) { item in
            DisclosureGroup(
                isExpanded: Binding(
                    get: { expandedItem == item.id },
                    set: { expandedItem = $0 ? item.id : nil }
                )
            ) {
                Text(item.answer)
            } label: {
                Text(item.question)
                    .font(.headline)
            }
        }
        .navigationTitle("faq".localized())
    }
}

struct FaqView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        FAQView()
    }
}

#Preview {
    FaqView()
}
