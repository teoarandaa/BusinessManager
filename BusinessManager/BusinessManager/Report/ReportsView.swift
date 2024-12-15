import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isShowingItemSheet1 = false
    @State private var isShowingItemSheet2 = false
    @Environment(\.modelContext) var context
    @Query(sort: [SortDescriptor(\Report.date, order: .reverse), 
                  SortDescriptor(\Report.departmentName)]) var reports: [Report]
    @Query var goals: [Goal]
    @State private var reportToEdit: Report?
    @State private var showingBottomSheet: Bool = false
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
                            Button("Add Report") { isShowingItemSheet1 = true }
                        })
                        .offset(y: -60)
                    } else if !searchText.isEmpty && filteredReports.isEmpty {
                        ContentUnavailableView.search(text: searchText)
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
                    Button("Settings", systemImage: "gear") {
                        isShowingSettings = true
                    }
                    Button("Information", systemImage: "info.circle") {
                        isShowingItemSheet2 = true
                    }
                }
            }
        }
    }
    
    private func deleteReport(_ report: Report) {
        context.delete(report)
        
        do {
            try context.save()
        } catch {
            print("Error deleting report: \(error)")
            return
        }
        
        let departmentGoals = goals.filter { goal in
            goal.department == report.departmentName && 
            goal.status == .inProgress
        }
        
        let remainingReports = reports.filter { 
            $0.departmentName == report.departmentName && 
            !$0.isDeleted
        }
        
        for goal in departmentGoals {
            switch goal.type {
            case .tasks:
                goal.currentValue -= report.numberOfFinishedTasks
                if goal.currentValue < 0 { goal.currentValue = 0 }
                
            case .performance:
                goal.currentValue = remainingReports.isEmpty ? 0 : (remainingReports.map(\.performanceMark).max() ?? 0)
                
            case .volume:
                goal.currentValue = remainingReports.isEmpty ? 0 : (remainingReports.map(\.volumeOfWorkMark).max() ?? 0)
            }
        }
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error saving goals after report deletion: \(error)")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
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
    @Query var goals: [Goal]
    
    @State private var date: Date = .now
    @State private var departmentName: String = ""
    @State private var performanceMark: String = ""
    @State private var volumeOfWorkMark: String = ""
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
                    TextField("0-100", text: $performanceMark)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(performanceMark.isEmpty ? .secondary : .primary)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("0-100", text: $volumeOfWorkMark)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(volumeOfWorkMark.isEmpty ? .secondary : .primary)
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
                        saveReport()
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
    
    private func saveReport() {
        guard let performance = Int(performanceMark),
              let volume = Int(volumeOfWorkMark),
              let tasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "Please enter valid numbers"
            return
        }
        
        // Validar rango de performance
        guard (0...100).contains(performance) else {
            showAlert = true
            alertMessage = "Performance must be between 0 and 100"
            return
        }
        
        // Validar rango de volume
        guard (0...100).contains(volume) else {
            showAlert = true
            alertMessage = "Volume of Work must be between 0 and 100"
            return
        }
        
        let trimmedDepartmentName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let report = Report(
            date: date,
            departmentName: trimmedDepartmentName,
            performanceMark: performance,
            volumeOfWorkMark: volume,
            numberOfFinishedTasks: tasks,
            annotations: trimmedAnnotations
        )
        
        context.insert(report)
        
        updateRelatedGoals(
            department: trimmedDepartmentName,
            performance: performance,
            volume: volume,
            tasks: tasks
        )
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Error saving report: \(error)")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func updateRelatedGoals(department: String, performance: Int, volume: Int, tasks: Int) {
        let activeGoals = goals.filter { goal in
            goal.status == .inProgress && goal.department == department
        }
        
        for goal in activeGoals {
            switch goal.type {
            case .performance:
                goal.currentValue = max(goal.currentValue, performance)
            case .volume:
                goal.currentValue = max(goal.currentValue, volume)
            case .tasks:
                goal.currentValue += tasks
            }
        }
    }
}

struct UpdateReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Query var goals: [Goal]
    @Query var reports: [Report]
    @Bindable var report: Report
    
    @State private var performanceMark: String
    @State private var volumeOfWorkMark: String
    @State private var numberOfFinishedTasks: String
    @State private var annotations: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(report: Report) {
        self.report = report
        _performanceMark = State(initialValue: String(report.performanceMark))
        _volumeOfWorkMark = State(initialValue: String(report.volumeOfWorkMark))
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
                    DatePicker("", selection: $report.date, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Department name")
                        .bold()
                    Spacer()
                    TextField("Name", text: $report.departmentName, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Performance")
                        .bold()
                    Spacer()
                    TextField("0-100", text: $performanceMark)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(performanceMark.isEmpty ? .secondary : .primary)
                }
                
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Volume of Work")
                        .bold()
                    Spacer()
                    TextField("0-100", text: $volumeOfWorkMark)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(volumeOfWorkMark.isEmpty ? .secondary : .primary)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Finished Tasks")
                        .bold()
                    Spacer()
                    TextField("Quantity", text: $numberOfFinishedTasks)
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
                    TextField("Extra info...", text: $report.annotations, axis: .vertical)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Update Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateReport()
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateReport() {
        guard let performance = Int(performanceMark),
              let volume = Int(volumeOfWorkMark),
              let tasks = Int(numberOfFinishedTasks) else {
            alertMessage = "Please enter valid numbers"
            showAlert = true
            return
        }
        
        // Validar rango de performance
        guard (0...100).contains(performance) else {
            alertMessage = "Performance must be between 0 and 100"
            showAlert = true
            return
        }
        
        // Validar rango de volume
        guard (0...100).contains(volume) else {
            alertMessage = "Volume of Work must be between 0 and 100"
            showAlert = true
            return
        }
        
        let oldTasks = report.numberOfFinishedTasks
        
        report.departmentName = report.departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        report.annotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        report.performanceMark = performance
        report.volumeOfWorkMark = volume
        report.numberOfFinishedTasks = tasks
        
        let departmentGoals = goals.filter { goal in
            goal.department == report.departmentName && 
            goal.status == .inProgress
        }
        
        for goal in departmentGoals {
            switch goal.type {
            case .tasks:
                goal.currentValue -= oldTasks
                goal.currentValue += tasks
                if goal.currentValue < 0 { goal.currentValue = 0 }
                
            case .performance:
                let maxPerformance = reports
                    .filter { $0.departmentName == report.departmentName }
                    .map(\.performanceMark)
                    .max() ?? 0
                goal.currentValue = maxPerformance
                
            case .volume:
                let maxVolume = reports
                    .filter { $0.departmentName == report.departmentName }
                    .map(\.volumeOfWorkMark)
                    .max() ?? 0
                goal.currentValue = maxVolume
            }
        }
        
        do {
            try context.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            alertMessage = "Error saving changes: \(error.localizedDescription)"
            showAlert = true
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
