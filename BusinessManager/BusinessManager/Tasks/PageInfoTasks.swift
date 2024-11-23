//
//  PageInfoCharts.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 23/11/24.
//

import Foundation
import SwiftUI


// MARK: - Code for WelcomeView -> ContentView()
// MARK: - Constants for distributing page information
struct PageInfoTasks: Identifiable {
    let id = UUID()
    let label: String
    let text: String
    let image: ImageResource
}

// MARK: - Array of pages. They contain the information for every page. Create a new one to create a new page that will automatically add
let pagesTasks = [
    PageInfoTasks(label: "Welcome to CleanCode", text: "We’re excited to have you! CleanCode helps you optimize your coding experience, making your projects cleaner and easier to maintain.", image: .tasksReports001),
    PageInfoTasks(label: "Benefits", text: "CleanCode provides offline programming knowledge, allowing you to explore languages and get instant coding tips anytime, anywhere.", image: .tasksReports002),
    PageInfoTasks(label: "Are you ready?", text: "Join us in revolutionizing the way you approach coding. Your exciting journey begins here, right now. Are you ready to take the first step? Let’s get started!", image: .tasksReports003)
]

// MARK: - Structure of the view for every page (UI)
struct WelcomeTasksView: View {
    @Binding var isWelcomeTasksSheetShowing: Bool
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pagesTasks.count, id: \.self) { index in
                    VStack {
                        Text(pagesTasks[index].label)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(height: 100)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Text(pagesTasks[index].text)
                            .fontWeight(.medium)
                            .padding()
                            .frame(height: 100)
                            .multilineTextAlignment(.leading)
                        
                        Image(pagesTasks[index].image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .tabViewStyle(.page)
            
            // MARK: - Last button. It appears when the user is in the last page
            Button {
                isWelcomeTasksSheetShowing.toggle()
            } label: {
                Text("Get started")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentColor)
            .padding()
            .opacity(currentPage == pagesTasks.count - 1 ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: currentPage)
        }
        .interactiveDismissDisabled()
    }
}
