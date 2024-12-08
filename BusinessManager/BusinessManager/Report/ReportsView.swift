import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @Environment(\.modelContext) var context
    @Query(sort: \Report.departmentName) var reports: [Report]
    @State private var reportToEdit: Report?
    @State private var showingBottomSheet: Bool = false
    @State private var isShowingMonthlySummary = false
    @State private var searchText = ""
    
    var filteredReports: [Report] {
        if searchText.isEmpty {
            return reports
        } else {
            return reports.filter { $0.departmentName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        if !filteredReports.isEmpty {
                            Button("Monthly Summary") {
                                isShowingMonthlySummary = true
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    ForEach(
                        Dictionary(grouping: filteredReports, by: { $0.departmentName })
                            .sorted(by: { $0.key < $1.key }),
                        id: \.key
                    ) { department, departmentReports in
                        NavigationLink(destination: DepartmentReportsView(departmentReports: departmentReports)) {
                            DepartmentCell(
                                departmentName: department,
                                reportsCount: departmentReports.count
                            )
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(filteredReports[index])
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }
                }
                .if(!reports.isEmpty) { view in
                    view.searchable(text: $searchText, prompt: "Search departments")
                        .searchSuggestions {
                            if searchText.isEmpty {
                                ForEach(reports.prefix(3)) { report in
                                    Text(report.departmentName)
                                        .searchCompletion(report.departmentName)
                                }
                            }
                        }
                }
                .navigationTitle("Departments")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet1) {
                    AddReportSheet()
                }
                .sheet(isPresented: $isShowingItemSheet2) {
                    ReportsInfoSheetView()
                        .presentationDetents([.height(700)])
                }
                .sheet(item: $reportToEdit) { report in
                    UpdateReportSheet(report: report)
                }
                .sheet(isPresented: $isShowingMonthlySummary) {
                    MonthlySummaryView()
                }
                .overlay {
                    if reports.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No Reports", systemImage: "text.document")
                        }, description: {
                            Text("Start adding reports to see your list.")
                        }, actions: {
                            Button("Add Report") { isShowingItemSheet1 = true }
                        })
                        .offset(y: -60)
                    }
                }
            }
            .toolbar {
                if !reports.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Add Task", systemImage: "plus") {
                            isShowingItemSheet1 = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Information", systemImage: "info.circle") {
                        isShowingItemSheet2 = true
                    }
                }
            }
        }
    }
}

#Preview {
    ReportsView()
}

struct ReportCell: View {
    let report: Report
    
    var body: some View {
        HStack {
            Text(report.date, format: .dateTime.year().month(.abbreviated).day())
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(report.departmentName)
                .bold()
            Spacer()
        }
    }
}

struct AddReportSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date = .now
    @State private var departmentName: String = ""
    @State private var performanceMark: Int = 0
    @State private var volumeOfWorkMark: Int = 0
    @State private var numberOfFinishedTasks: Int = 0
    @State private var annotations: String = ""
    
    // State variables for alerts
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date")
                        .bold()
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Department name")
                        .bold()
                    Spacer()
                    TextField("", text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Performance")
                        .bold()
                    Spacer()
                    TextField("", value: $performanceMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("", value: $volumeOfWorkMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("", value: $numberOfFinishedTasks, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("", text: $annotations, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { 
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss() 
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let currentDate = Date()
                        if date > currentDate {
                            alertMessage = "The report date cannot be in the future."
                            showAlert = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        } else {
                            let newReport = Report(date: date, departmentName: departmentName, performanceMark: performanceMark, volumeOfWorkMark: volumeOfWorkMark, numberOfFinishedTasks: numberOfFinishedTasks, annotations: annotations)
                            context.insert(newReport)
                            do {
                                try context.save()
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                dismiss()
                            } catch {
                                print("Failed to save report: \(error)")
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.error)
                            }
                        }
                    }
                }
            }
            .alert("Invalid Date", isPresented: $showAlert) {
                Button("OK", role: .cancel) { 
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct UpdateReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Bindable var report: Report
    
    // Añadidas variables para el alert
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date")
                        .bold()
                    Spacer()
                    DatePicker("", selection: $report.date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Department name")
                        .bold()
                    Spacer()
                    TextField("", text: $report.departmentName, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Performance")
                        .bold()
                    Spacer()
                    TextField("", value: $report.performanceMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("", value: $report.volumeOfWorkMark, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("", value: $report.numberOfFinishedTasks, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("", text: $report.annotations, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { 
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss() 
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let currentDate = Date()
                        if report.date > currentDate {
                            alertMessage = "The report date cannot be in the future."
                            showAlert = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        } else {
                            do {
                                try context.save()
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                dismiss()
                            } catch {
                                print("Failed to save updated report: \(error)")
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.error)
                            }
                        }
                    }
                }
            }
            .alert("Invalid Date", isPresented: $showAlert) {
                Button("OK", role: .cancel) { 
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// Extensión para el modificador condicional
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct DepartmentCell: View {
    let departmentName: String
    let reportsCount: Int
    @State private var isEditingDepartment = false
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
    @Environment(\.modelContext) var context
    @Query(sort: \Report.date) var reports: [Report]
    
    var currentIcon: String {
        let dictionary = (try? JSONDecoder().decode([String: String].self, 
            from: Data(iconStorage.utf8))) ?? [:]
        return dictionary[departmentName] ?? "building.2"
    }
    
    let icons = [
        ("person.2.wave.2", "Human Resources"),
        ("chart.pie", "Analytics"),
        ("megaphone", "Marketing"),
        ("cart", "Sales"),
        ("wrench.and.screwdriver", "Maintenance"),
        ("desktopcomputer", "IT"),
        ("text.page.badge.magnifyingglass", "Research"),
        ("gearshape", "Operations"),
        ("lightbulb", "Innovation"),
        ("bubble.left.and.bubble.right", "Communication"),
        ("pencil.and.outline", "Design"),
        ("shield.checkerboard", "Security"),
        ("truck.box", "Logistics"),
        ("checkmark.seal", "Quality"),
        ("target", "Strategy")
    ]
    
    var body: some View {
        HStack {
            Image(systemName: currentIcon)
                .foregroundStyle(.accent)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(departmentName)
                    .font(.headline)
                Text("\(reportsCount) reports")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
        .contextMenu {
            Button {
                isEditingDepartment = true
            } label: {
                Label("Change Department Name", systemImage: "pencil")
            }
            
            Menu("Change Icon") {
                ForEach(icons, id: \.0) { icon in
                    Button {
                        var dictionary = (try? JSONDecoder().decode([String: String].self, 
                            from: Data(iconStorage.utf8))) ?? [:]
                        dictionary[departmentName] = icon.0
                        if let encoded = try? JSONEncoder().encode(dictionary),
                           let string = String(data: encoded, encoding: .utf8) {
                            iconStorage = string
                        }
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        Label(icon.1, systemImage: icon.0)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingDepartment) {
            EditDepartmentSheet(departmentName: departmentName, reports: reports)
        }
    }
}

struct EditDepartmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    let departmentName: String
    let reports: [Report]
    
    @State private var newDepartmentName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Department Name", text: $newDepartmentName)
                }
            }
            .navigationTitle("Edit Department")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Actualizar el nombre del departamento en todos los reports asociados
                        for report in reports where report.departmentName == departmentName {
                            report.departmentName = newDepartmentName
                        }
                        
                        do {
                            try context.save()
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            dismiss()
                        } catch {
                            print("Error saving context: \(error)")
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        }
                    }
                    .disabled(newDepartmentName.isEmpty)
                }
            }
            .onAppear {
                newDepartmentName = departmentName
            }
        }
    }
}
