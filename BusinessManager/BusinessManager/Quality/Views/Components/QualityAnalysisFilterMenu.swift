import SwiftUI

struct QualityAnalysisFilterMenu: View {
    @Binding var selectedTimeFrame: TimeFrame
    @Binding var selectedDepartment: String?
    let departments: [String]
    
    var body: some View {
        HStack {
            Menu {
                // Time Frame Picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Label(timeFrame.rawValue, systemImage: timeFrame.systemImage)
                            .tag(timeFrame)
                    }
                }
                
                Divider()
                
                // Department Picker
                Menu("Department") {
                    Button("All Departments") {
                        selectedDepartment = nil
                    }
                    
                    Divider()
                    
                    ForEach(departments.sorted(), id: \.self) { department in
                        Button(department) {
                            selectedDepartment = department
                        }
                        .foregroundStyle(selectedDepartment == department ? .blue : .primary)
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
            
            if let department = selectedDepartment {
                Text(department)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.1))
                    }
            }
            
            Spacer()
        }
    }
}