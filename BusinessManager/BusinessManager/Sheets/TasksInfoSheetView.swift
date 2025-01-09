import SwiftUI

struct TasksInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                // First Page
                ScrollView {
                    VStack {
                        Image(systemName: "list.clipboard.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("tasks_overview".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("overview".localized())
                }
                
                // Second Page
                ScrollView {
                    VStack {
                        Image(systemName: "plus.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("how_create_tasks".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("tasks_creation_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("managing_tasks".localized())
                }
                
                // Third Page
                ScrollView {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("sort_tasks".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("sort_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("sort".localized())
                }
                
                // Fourth Page
                ScrollView {
                    VStack {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .padding(.top, 40)
                        
                        Text("add_task".localized())
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("add_task_description".localized())
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .tabItem {
                    Text("add_task".localized())
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ok".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TasksInfoSheetView()
}
