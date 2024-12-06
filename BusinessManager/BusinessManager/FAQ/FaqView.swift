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
        FAQItem(question: "What is Business Manager", answer: "Business Manager is the tool for managing and optimizing internal business processes effectively. If you are interested in learning more about it, please visit our website: https://www.example.app/"),
        FAQItem(question: "Is Business Manager free to use?", answer: "There is an initial trial period, and afterward, you can choose from several plans: \n\n- Self-employed: Free.\n\n- Startup: €4.99/month or €46.99/year.\n\n- SME: €9.99/month or €94.99/year.\n\n- Corporation: €14.99/month or €142.99/year.\n\n- Enterprise: €19.99/month or €190.99/year.\n\nTo access the plans, please go to Settings > Subscription Packages, where you can review what each plan includes."),
        FAQItem(question: "How often do you add new features to the app?", answer: "Each update comes with new features and improvements. Exciting, isn't it?"),
        FAQItem(question: "Are there frequent updates to the app?", answer: "We ensure a minimum of one major update per year, introducing new features, enhancements, and resolving bugs."),
        FAQItem(question: "How do I enable push notifications?", answer: "To enable push notifications, navigate to Settings > Notifications and switch them on for the app."),
        FAQItem(question: "Is the app available in multiple languages?", answer: "Currently, the app is available only in English, but we are working on introducing more languages soon."),
        FAQItem(question: "What payment methods do you accept?", answer: "We accept all major credit cards and Apple Pay for premium subscriptions and features."),
        FAQItem(question: "Where can I find the privacy policy?", answer: "You can access the privacy policy by navigating to Settings > Privacy > Privacy Policy."),
        FAQItem(question: "What should I do if I encounter technical issues?", answer: "For any technical issues, please email us at help.businessmanager@gmail.com, and we'll assist you as quickly as possible."),
        FAQItem(question: "How can I contact support?", answer: "Reach out to our support team by sending an email to help.businessmanager@gmail.com."),
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
        .navigationTitle("FAQ")
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
