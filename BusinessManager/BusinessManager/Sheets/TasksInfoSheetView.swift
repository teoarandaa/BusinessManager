//
//  TasksInfoSheetView.swift
//  BusinessManager
//
//  Created by Teo Aranda Páez on 20/11/24.
//

import SwiftUI

struct TasksInfoSheetView: View {
    var body: some View {
        TabView {
            // First Page
            VStack {
                Text("Tasks Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("This section provides an overview of the tasks.")
                    .padding()
                
                Image("tasks_overview") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            .tabItem {
                Text("Overview")
            }
            
            // Second Page
            VStack {
                Text("How to Manage Tasks")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Follow these steps to manage your tasks effectively...")
                    .padding()
                
                Image("manage_tasks") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            .tabItem {
                Text("Managing Tasks")
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

#Preview {
    TasksInfoSheetView()
}
