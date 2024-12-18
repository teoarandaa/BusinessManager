import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingAddReportSheet = false
    @State private var isShowingInfoSheet = false
    @Environment(\.modelContext) var context

    @Query(sort: \Report.date, animation: .default) private var reports: [Report]
    
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
                .if(!reports.isEmpty) { view in
                    view.searchable(text: $searchText, prompt: "Search departments")
                        .searchSuggestions {
                            if searchText.isEmpty {
                                ForEach(reports.prefix(3)) { report in
                                    Label(report.departmentName, systemImage: "magnifyingglass")
                                        .searchCompletion(report.departmentName)
                                }
                            }
                        }
                }
                .navigationTitle("Departments")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            isShowingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        Button {
                            isShowingInfoSheet = true
                        } label: {
                            Label("Info", systemImage: "info.circle")
                        }
                    }
                    
                    if !reports.isEmpty {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                isShowingMonthlySummary = true
                            } label: {
                                Label("Monthly Summary", systemImage: "calendar.badge.clock")
                            }
                            .tint(.red)
                            
                            Button {
                                isShowingAddReportSheet = true
                            } label: {
                                Label("Add Report", systemImage: "plus")
                            }
                        }
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
                    Text("Department")
                        .bold()
                    Spacer()
                    TextField("Name", text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Tasks created")
                        .bold()
                    Spacer()
                    TextField("Number", text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("On-Time Tasks")
                        .bold()
                    Spacer()
                    TextField("Number", text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("Number", text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("Add note", text: $annotations, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Add Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        saveReport()
                    }
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
        // Validar que la fecha no sea futura
        guard date <= Date() else {
            showAlert = true
            alertMessage = "Cannot create reports for future dates."
            return
        }

        // Convertir Strings a Ints
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "Please enter valid numbers for tasks."
            return
        }
        
        // Validaciones
        guard totalTasks >= 0 else {
            showAlert = true
            alertMessage = "Total tasks cannot be negative."
            return
        }
        
        // Nueva validación sin haptic feedback
        guard finishedTasks >= tasksWithoutDelay else {
            showAlert = true
            alertMessage = "Finished tasks must be equal to or greater than tasks completed on time."
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
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
    
    var departmentIcon: String {
        let dictionary = (try? JSONDecoder().decode([String: String].self, from: Data(iconStorage.utf8))) ?? [:]
        return dictionary[departmentName] ?? "building.2"
    }
    
    var body: some View {
        HStack {
            Image(systemName: departmentIcon)
                .font(.system(size: 16))
                .foregroundStyle(.accent)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(departmentName)
                    .font(.system(size: 16))
                Text("\(reportsCount) reports")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
                    Text("Department")
                        .bold()
                    Spacer()
                    TextField("Name", text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Tasks created")
                        .bold()
                    Spacer()
                    TextField("Number", text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("On-Time Tasks")
                        .bold()
                    Spacer()
                    TextField("Number", text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("Number", text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(numberOfFinishedTasks.isEmpty ? .secondary : .primary)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    Text("Annotations")
                        .bold()
                    Spacer()
                    TextField("Add note", text: $annotations, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
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
        // Validar que la fecha no sea futura
        guard date <= Date() else {
            showAlert = true
            alertMessage = "Cannot create reports for future dates."
            return
        }

        // Convertir Strings a Ints
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "Please enter valid numbers for tasks."
            return
        }
        
        // Validaciones básicas
        guard totalTasks >= 0 else {
            showAlert = true
            alertMessage = "Total tasks cannot be negative."
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
