import SwiftUI
import SwiftData

struct ReportsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("iCloudSync") private var iCloudSync = false
    @State private var isShowingAddReportSheet = false
    @State private var isShowingInfoSheet = false
    @Environment(\.modelContext) var context

    @Query(sort: \Report.date, animation: .default) private var reports: [Report]
    
    @State private var reportToEdit: Report?
    @State private var isShowingMonthlySummary = false
    @State private var searchText = ""
    @State private var isShowingSettings = false
    
    @State private var forceRefresh: Bool = false
    
    @State private var departmentToDelete: String?
    @State private var showDeleteAlert = false
    
    @AppStorage("lastSyncDate") private var lastSyncDate = Date()
    @AppStorage("isNetworkAvailable") private var isNetworkAvailable = false
    
    @State private var isLoading = true // Añadir estado de carga
    
    var filteredReports: [Report] {
        if searchText.isEmpty {
            return reports
        } else {
            return reports.filter { $0.departmentName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var groupedAndSortedReports: [(key: String, value: [Report])] {
        let grouped = Dictionary(grouping: filteredReports, by: { $0.departmentName })
        return grouped.sorted(by: { $0.key < $1.key })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading && iCloudSync {
                    ProgressView("syncing_data".localized())
                        .progressViewStyle(.circular)
                } else {
                    List {
                        ForEach(groupedAndSortedReports, id: \.key) { department, departmentReports in
                            NavigationLink(destination: DepartmentReportsView(departmentName: department)) {
                                DepartmentCell(
                                    departmentName: department,
                                    reportsCount: departmentReports.count,
                                    reports: departmentReports
                                )
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    departmentToDelete = department
                                    showDeleteAlert = true
                                } label: {
                                    Label("", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .if(!reports.isEmpty) { view in
                        view.searchable(text: $searchText, prompt: "search_departments".localized())
                            .searchSuggestions {
                                if searchText.isEmpty {
                                    ForEach(reports.prefix(3)) { report in
                                        Label(report.departmentName, systemImage: "magnifyingglass")
                                            .searchCompletion(report.departmentName)
                                    }
                                }
                            }
                    }
                    .navigationTitle("departments".localized())
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            HStack(spacing: 16) {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Label("settings".localized(), systemImage: "gear")
                                }
                                Button {
                                    isShowingInfoSheet = true
                                } label: {
                                    Label("information".localized(), systemImage: "info.circle")
                                }
                                Menu {
                                    if !isNetworkAvailable {
                                        Text("network_unavailable".localized())
                                    } else if !iCloudSync {
                                        Text("icloud_disabled".localized())
                                    } else {
                                        Text("last_sync".localized() + ": ")
                                        + Text(lastSyncDate, style: .date)
                                        + Text(" ")
                                        + Text(lastSyncDate, style: .time)
                                    }
                                } label: {
                                    Label("iCloud".localized(), systemImage: iCloudSync ? "checkmark.icloud" : "xmark.icloud")
                                        .foregroundStyle(iCloudSync ? .green : .red)
                                }
                            }
                        }
                        
                        if !reports.isEmpty {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button {
                                    isShowingMonthlySummary = true
                                } label: {
                                    Label("monthly_summary".localized(), systemImage: "calendar.badge.clock")
                                }
                                .tint(.red)
                                
                                Button {
                                    isShowingAddReportSheet = true
                                } label: {
                                    Label("add_report".localized(), systemImage: "plus")
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $isShowingAddReportSheet) {
                        AddReportSheet()
                    }
                    .sheet(isPresented: $isShowingInfoSheet) {
                        ReportsInfoSheetView()
                            .presentationDetents([.height(550)])
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
                                Label("no_reports".localized(), systemImage: "text.document")
                            }, description: {
                                Text("start_adding_reports".localized())
                            }, actions: {
                                Button {
                                    isShowingAddReportSheet = true
                                } label: {
                                    Label("add_report".localized(), systemImage: "plus")
                                }
                            })
                            .offset(y: -60)
                        } else if !searchText.isEmpty && filteredReports.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Simular tiempo de carga de iCloud
            if iCloudSync {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoading = false
                }
            } else {
                isLoading = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .reportDidUpdate)) { _ in
            forceRefresh.toggle() // Esto forzará una actualización de la vista
        }
        .alert("delete_department_title".localized(), isPresented: $showDeleteAlert) {
            Button("cancel".localized(), role: .cancel) {
                departmentToDelete = nil
            }
            Button("delete".localized(), role: .destructive) {
                if let department = departmentToDelete {
                    for report in reports where report.departmentName == department {
                        deleteReport(report)
                    }
                }
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                departmentToDelete = nil
            }
        } message: {
            Text("delete_department_message".localized())
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
                .frame(width: 150, alignment: .leading)
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
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
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
                    Text("date".localized())
                        .bold()
                    Spacer()
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .fixedSize()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("department".localized())
                        .bold()
                    Spacer()
                    TextField("name".localized(), text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "plus.circle")
                    Text("tasks_created".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("completed_on_time".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("completed_tasks".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    VStack(alignment: .leading) {
                        Text("annotations".localized())
                            .bold()
                        TextField("add_note".localized(), text: $annotations, axis: .vertical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4...6)
                    }
                }
            }
            .navigationTitle("add_report".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized()) {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        saveReport()
                    }
                    .disabled(departmentName.isEmpty || totalTasksCreated.isEmpty || tasksCompletedWithoutDelay.isEmpty || numberOfFinishedTasks.isEmpty)
                }
            }
            .alert("invalid_input".localized(), isPresented: $showAlert) {
                Button("ok".localized(), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveReport() {
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "err_valid_num".localized()
            return
        }
        
        guard totalTasks >= 0 else {
            showAlert = true
            alertMessage = "err_negative_totalTasks".localized()
            return
        }
        
        let trimmedDepartmentName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Crear el reporte con los valores calculados
        let report = Report(
            date: date,
            departmentName: trimmedDepartmentName,
            totalTasksCreated: totalTasks,
            tasksCompletedWithoutDelay: tasksWithoutDelay,
            numberOfFinishedTasks: finishedTasks,
            annotations: trimmedAnnotations
        )
        
        // Calcular las métricas
        report.performanceMark = report.calculatePerformance()
        report.volumeOfWorkMark = report.calculateVolumeOfWork()
        
        context.insert(report)
        
        // Asegurarse de que el nuevo departamento tenga el icono por defecto
        if let data = iconStorage.data(using: .utf8),
           var dictionary = try? JSONDecoder().decode([String: String].self, from: data) {
            if dictionary[trimmedDepartmentName] == nil {
                dictionary[trimmedDepartmentName] = "building.2"
                if let encoded = try? JSONEncoder().encode(dictionary),
                   let string = String(data: encoded, encoding: .utf8) {
                    iconStorage = string
                }
            }
        } else {
            // Si no hay iconos guardados, crear un nuevo diccionario con el icono por defecto
            let dictionary = [trimmedDepartmentName: "building.2"]
            if let encoded = try? JSONEncoder().encode(dictionary),
               let string = String(data: encoded, encoding: .utf8) {
                iconStorage = string
            }
        }
        
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
    @State private var isShowingEditSheet = false
    @State private var isShowingIconPicker = false
    @Environment(\.modelContext) private var context
    let reports: [Report]
    
    private var currentIcon: String {
        if let data = iconStorage.data(using: .utf8),
           let dictionary = try? JSONDecoder().decode([String: String].self, from: data) {
            return dictionary[departmentName] ?? "building.2"
        }
        return "building.2"
    }
    
    var body: some View {
        HStack {
            Image(systemName: currentIcon)
                .foregroundStyle(.accent)
            
            VStack(alignment: .leading) {
                Text(departmentName)
                    .font(.headline)
                Text("\(reportsCount) " + (reportsCount == 1 ? "report".localized() : "reports".localized()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .contextMenu {
            Button {
                isShowingEditSheet = true
            } label: {
                Label("edit_name".localized(), systemImage: "pencil")
            }
            
            Button {
                isShowingIconPicker = true
            } label: {
                Label("change_icon".localized(), systemImage: "photo")
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditDepartmentSheet(departmentName: departmentName, reports: reports)
        }
        .sheet(isPresented: $isShowingIconPicker) {
            IconPickerView(departmentName: departmentName)
        }
    }
}

// Primero definimos las estructuras necesarias
struct IconItem: Identifiable {
    let id = UUID()
    let icon: String
}

struct IconSection: Identifiable {
    let id = UUID()
    let title: String
    let icons: [IconItem]
}

// Luego las variables y datos necesarios
let categories = [
    "all".localized(),
    "general".localized(),
    "tech".localized(),
    "business".localized(),
    "communication".localized()
]

let sections = [
    IconSection(title: "general".localized(), icons: [
        IconItem(icon: "building.2"),
        IconItem(icon: "building.columns"),
        IconItem(icon: "building"),
        IconItem(icon: "house"),
        IconItem(icon: "briefcase"),
        IconItem(icon: "folder"),
        IconItem(icon: "doc"),
        IconItem(icon: "chart.bar"),
        IconItem(icon: "chart.pie"),
        IconItem(icon: "chart.line.uptrend.xyaxis")
    ]),
    IconSection(title: "tech".localized(), icons: [
        IconItem(icon: "desktopcomputer"),
        IconItem(icon: "laptopcomputer"),
        IconItem(icon: "keyboard"),
        IconItem(icon: "printer"),
        IconItem(icon: "network"),
        IconItem(icon: "server.rack"),
        IconItem(icon: "cpu"),
        IconItem(icon: "memorychip"),
        IconItem(icon: "display"),
        IconItem(icon: "pc")
    ]),
    IconSection(title: "business".localized(), icons: [
        IconItem(icon: "creditcard"),
        IconItem(icon: "banknote"),
        IconItem(icon: "dollarsign.circle"),
        IconItem(icon: "chart.bar.doc.horizontal"),
        IconItem(icon: "newspaper"),
        IconItem(icon: "case"),
        IconItem(icon: "case.fill"),
        IconItem(icon: "signature"),
        IconItem(icon: "pencil.and.outline"),
        IconItem(icon: "list.clipboard")
    ]),
    IconSection(title: "communication".localized(), icons: [
        IconItem(icon: "message"),
        IconItem(icon: "phone"),
        IconItem(icon: "envelope"),
        IconItem(icon: "bell"),
        IconItem(icon: "megaphone"),
        IconItem(icon: "bubble.left"),
        IconItem(icon: "bubble.right"),
        IconItem(icon: "mail.stack"),
        IconItem(icon: "text.bubble"),
        IconItem(icon: "phone.circle")
    ])
]

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
    let departmentName: String
    @State private var selectedIcon: String = "building.2"
    @State private var selectedCategory: String = "all".localized()
    
    var filteredSections: [IconSection] {
        selectedCategory == "all".localized() ? sections : sections.filter { $0.title == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtro horizontal
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == category ? 
                                             Color.accentColor : Color.gray.opacity(0.2))
                                )
                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                                .onTapGesture {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Contenido principal
                List {
                    ForEach(filteredSections) { section in
                        Section(header: Text(section.title)) {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 44))
                            ], spacing: 10) {
                                ForEach(section.icons) { icon in
                                    Image(systemName: icon.icon)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon.icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedIcon = icon.icon
                                            let generator = UISelectionFeedbackGenerator()
                                            generator.selectionChanged()
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("select_icon".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        updateIcon(to: selectedIcon)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedIcon = getCurrentIcon()
            print("IconPicker - Opened with current icon: \(selectedIcon)")
        }
    }
    
    private func getCurrentIcon() -> String {
        if let data = iconStorage.data(using: .utf8),
           let dictionary = try? JSONDecoder().decode([String: String].self, from: data),
           let icon = dictionary[departmentName] {
            return icon
        }
        return "building.2"
    }
    
    private func updateIcon(to icon: String) {
        var dictionary: [String: String] = [:]
        
        if let data = iconStorage.data(using: .utf8),
           let existingDictionary = try? JSONDecoder().decode([String: String].self, from: data) {
            dictionary = existingDictionary
        }
        
        print("IconPicker - Before update: \(dictionary)")
        dictionary[departmentName] = icon
        print("IconPicker - After update: \(dictionary)")
        
        if let encodedData = try? JSONEncoder().encode(dictionary),
           let encodedString = String(data: encodedData, encoding: .utf8) {
            iconStorage = encodedString
            print("IconPicker - Saved to storage: \(iconStorage)")
        }
        
        NotificationCenter.default.post(name: .departmentIconDidChange, object: nil)
    }
}

// Componente separado para la celda del icono
struct IconCell: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .frame(width: 60, height: 60)
            
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? .accent : .primary)
            
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
        }
        .frame(width: 80, height: 80)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
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
    
    private func updateReport() {
        guard let totalTasks = Int(totalTasksCreated),
              let tasksWithoutDelay = Int(tasksCompletedWithoutDelay),
              let finishedTasks = Int(numberOfFinishedTasks) else {
            showAlert = true
            alertMessage = "err_valid_num".localized()
            return
        }
        
        guard totalTasks >= 0 else {
            showAlert = true
            alertMessage = "err_negative_totalTasks".localized()
            return
        }
        
        report.date = date
        let trimmedDepartmentName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnotations = annotations.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Crear el reporte actualizado con los valores calculados
        let updatedReport = Report(
            date: date,
            departmentName: trimmedDepartmentName,
            totalTasksCreated: totalTasks,
            tasksCompletedWithoutDelay: tasksWithoutDelay,
            numberOfFinishedTasks: finishedTasks,
            annotations: trimmedAnnotations
        )
        
        // Calcular las métricas
        updatedReport.performanceMark = updatedReport.calculatePerformance()
        updatedReport.volumeOfWorkMark = updatedReport.calculateVolumeOfWork()
        
        // Actualizar el reporte existente
        context.delete(report)
        context.insert(updatedReport)
        
        do {
            try context.save()
            NotificationCenter.default.post(name: .reportDidUpdate, object: nil)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            context.rollback()
            showAlert = true
            alertMessage = "Failed to save changes: \(error.localizedDescription)"
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Image(systemName: "calendar")
                    Text("date".localized())
                        .bold()
                    Spacer()
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .fixedSize()
                        .padding(.trailing, -8)
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("department".localized())
                        .bold()
                    Spacer()
                    TextField("name".localized(), text: $departmentName, axis: .vertical)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "plus.circle")
                    Text("tasks_created".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $totalTasksCreated)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("completed_on_time".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $tasksCompletedWithoutDelay)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("completed_tasks".localized())
                        .bold()
                    Spacer()
                    TextField("number".localized(), text: $numberOfFinishedTasks)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(numberOfFinishedTasks.isEmpty ? .secondary : .primary)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "pencil")
                    VStack(alignment: .leading) {
                        Text("annotations".localized())
                            .bold()
                        TextField("add_note".localized(), text: $annotations, axis: .vertical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4...6)
                    }
                }
            }
            .navigationTitle("edit_report".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized()) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized()) { updateReport() }
                        .disabled(departmentName.isEmpty || totalTasksCreated.isEmpty || tasksCompletedWithoutDelay.isEmpty || numberOfFinishedTasks.isEmpty)
                }
            }
            .alert("invalid_input".localized(), isPresented: $showAlert) {
                Button("ok".localized(), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
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
                    TextField("department_name".localized(), text: $newDepartmentName)
                }
            }
            .navigationTitle("edit_department".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized()) {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("save".localized()) {
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

extension Notification.Name {
    static let departmentIconDidChange = Notification.Name("departmentIconDidChange")
    static let reportDidUpdate = Notification.Name("reportDidUpdate")
}
