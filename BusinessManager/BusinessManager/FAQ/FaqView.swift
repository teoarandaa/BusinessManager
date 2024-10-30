//
//  FaqView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 30/10/24.
//

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
        FAQItem(question: "What is CleanCode", answer: "CleanCode is the tool for the developers to optimize their code and make it more readable and maintainable."),
        FAQItem(question: "Is CleanCode free to use?", answer: "The essentials of CleanCode are free to use. Who knows, you might find some extra features for free too!"),
        FAQItem(question: "How often do you add new languages to the app?", answer: "Every update will came up with new languages. Isn't it great?"),
        FAQItem(question: "Are there frequent updates to the app?", answer: "Minimum one update per year, where you will find new languages, features, bug fixes, and improvements."),
        FAQItem(question: "How do I enable push notifications?", answer: "You can enable push notifications by going to 'Settings' > 'Notifications' and toggling them on for the app."),
        FAQItem(question: "Is the app available in multiple languages?", answer: "For now, the app is available in English only. We are working on adding more languages soon."),
        FAQItem(question: "What payment methods do you accept?", answer: "We accept major credit cards and Apple Pay for online purchases and the tip jar."),
        FAQItem(question: "Where can I find the privacy policy", answer: "You can find privacy policy by going to 'Settings' > 'Privacy' > 'Privacy Policy'"),
        FAQItem(question: "What should I do if I encounter technical issues?", answer: "If you find any technical issues, please send us an email to support@example.com. We will do our best to help you out."),
        FAQItem(question: "How can I contact support?", answer: "You can contact support by sending an email to support@example.com.")
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
