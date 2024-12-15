import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingAddReportSheet = false
    @State private var isShowingInfoSheet = false
    @Environment(\.modelContext) var context

    @Query(sort: \Report.date, animation: .default) private var reports: [Report]
    @Query(sort: \Goal.deadline, animation: .default) private var goals: [Goal]
    
    @State private var reportToEdit: Report?
    @State private var isShowingMonthlySummary = false
    @State private var searchText = ""
    @State private var isShowingSettings = false
    
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
                            let departmentToDelete = Array(Dictionary(grouping: filteredReports, by: { $0.departmentName })
                                .sorted(by: { $0.key < $1.key }))[index]
                            
                            // Eliminar todos los reports del departamento
                            for report in reports where report.departmentName == departmentToDelete.key {
                                deleteReport(report)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search departments")
                .searchSuggestions {
                    if searchText.isEmpty {
                        ForEach(reports.prefix(3)) { report in
                            Label(report.departmentName, systemImage: "magnifyingglass")
                                .searchCompletion(report.departmentName)
                        }
                    }
                }
                .navigationTitle("Departments")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Settings") { isShowingSettings = true }
                        Button("Info") { isShowingInfoSheet = true }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Add Report") { isShowingAddReportSheet = true }
                    }
                }
                .sheet(isPresented: $isShowingAddReportSheet) {
                    AddReportSheet()
                }
                .sheet(isPresented: $isShowingInfoSheet) {
                    ReportsInfoSheetView()
                        .presentationDetents([.height(700)])
                }
                .sheet(item: $reportToEdit) { report in
                    UpdateReportSheet(report: report)
                }
                .sheet(isPresented: $isShowingMonthlySummary) {
                    MonthlySummaryView()
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView()
                }
                .overlay {
                    if reports.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No Reports", systemImage: "text.document")
                        }, description: {
                            Text("Start adding reports to see your list.")
                        }, actions: {
                            Button("Add Report") { isShowingAddReportSheet = true }
                        })
                        .offset(y: -60)
                    } else if !searchText.isEmpty && filteredReports.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
        }
    }
    
    // Función para eliminar un reporte
    private func deleteReport(_ report: Report) {
        context.delete(report)
        
        do {
            try context.save()
        } catch {
            print("Error deleting report: \(error)")
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
    @State private var totalTasksCreated: String = ""
    @State private var tasksCompletedWithoutDelay: String = ""
    @State private var numberOfFinishedTasks: String = ""
    @State private var annotations: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Report Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Department Name", text: $departmentName)
                    
                    TextField("Total Tasks Created", text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                    
                    TextField("Tasks Completed Without Delay", text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                    
                    TextField("Number of Finished Tasks", text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                    
                    TextEditor(text: $annotations)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .navigationTitle("Add Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveReport() }
                        .disabled(departmentName.isEmpty || totalTasksCreated.isEmpty || tasksCompletedWithoutDelay.isEmpty || numberOfFinishedTasks.isEmpty)
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveReport() {
        // Convertir Strings a Ints
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "Please enter valid numbers for tasks."
            return
        }
        
        // Validaciones
        guard tasksWithoutDelay <= totalTasks else {
            showAlert = true
            alertMessage = "Tasks completed without delay cannot exceed total tasks created."
            return
        }
        
        guard finishedTasks <= totalTasks else {
            showAlert = true
            alertMessage = "Finished tasks cannot exceed total tasks created."
            return
        }
        
        let trimmedDepartmentName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let report = Report(
            date: date,
            departmentName: trimmedDepartmentName,
            totalTasksCreated: totalTasks,
            tasksCompletedWithoutDelay: tasksWithoutDelay,
            numberOfFinishedTasks: finishedTasks,
            annotations: trimmedAnnotations
        )
        
        context.insert(report)
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            showAlert = true
            alertMessage = "Failed to save the report: \(error.localizedDescription)"
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
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
        HStack(spacing: 12) {
            Image(systemName: currentIcon)
                .foregroundStyle(.accent)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(departmentName)
                    .font(.headline)
                Text("\(reportsCount) reports")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
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

struct UpdateReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Bindable var report: Report
    
    @State private var date: Date
    @State private var departmentName: String
    @State private var totalTasksCreated: String
    @State private var tasksCompletedWithoutDelay: String
    @State private var numberOfFinishedTasks: String
    @State private var annotations: String
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(report: Report) {
        self.report = report
        _date = State(initialValue: report.date)
        _departmentName = State(initialValue: report.departmentName)
        _totalTasksCreated = State(initialValue: String(report.totalTasksCreated))
        _tasksCompletedWithoutDelay = State(initialValue: String(report.tasksCompletedWithoutDelay))
        _numberOfFinishedTasks = State(initialValue: String(report.numberOfFinishedTasks))
        _annotations = State(initialValue: report.annotations)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Update Report")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Department Name", text: $departmentName)
                    
                    TextField("Total Tasks Created", text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                    
                    TextField("Tasks Completed Without Delay", text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                    
                    TextField("Number of Finished Tasks", text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                    
                    TextEditor(text: $annotations)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { updateReport() }
                        .disabled(departmentName.isEmpty || totalTasksCreated.isEmpty || tasksCompletedWithoutDelay.isEmpty || numberOfFinishedTasks.isEmpty)
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateReport() {
        // Convertir Strings a Ints
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "Please enter valid numbers for tasks."
            return
        }
        
        // Validaciones
        guard tasksWithoutDelay <= totalTasks else {
            showAlert = true
            alertMessage = "Tasks completed without delay cannot exceed total tasks created."
            return
        }
        
        guard finishedTasks <= totalTasks else {
            showAlert = true
            alertMessage = "Finished tasks cannot exceed total tasks created."
            return
        }
        
        let trimmedDepartmentName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Actualizar report
        report.date = date
        report.departmentName = trimmedDepartmentName
        report.totalTasksCreated = totalTasks
        report.tasksCompletedWithoutDelay = tasksWithoutDelay
        report.numberOfFinishedTasks = finishedTasks
        report.annotations = trimmedAnnotations
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            showAlert = true
            alertMessage = "Failed to save changes: \(error.localizedDescription)"
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

struct EditDepartmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
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
                        // Actualizar el icono con el nuevo nombre del departamento
                        var dictionary = (try? JSONDecoder().decode([String: String].self, from: Data(iconStorage.utf8))) ?? [:]
                        if let icon = dictionary[departmentName] {
                            dictionary[newDepartmentName] = icon
                            dictionary.removeValue(forKey: departmentName)
                            if let encoded = try? JSONEncoder().encode(dictionary),
                               let string = String(data: encoded, encoding: .utf8) {
                                iconStorage = string
                            }
                        }
                        
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
