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
                                reportsCount: departmentReports.count,
                                reports: departmentReports
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
    @State private var isShowingEditSheet = false
    @State private var isShowingIconPicker = false
    @Environment(\.modelContext) private var context
    let reports: [Report]
    
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
        .contextMenu {
            Button {
                isShowingEditSheet = true
            } label: {
                Label("Edit Name", systemImage: "pencil")
            }
            
            Button {
                isShowingIconPicker = true
            } label: {
                Label("Change Icon", systemImage: "photo")
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

// Añadir esta nueva vista para seleccionar iconos
struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("departmentIcons") private var iconStorage: String = "{}"
    let departmentName: String
    @State private var selectedIcon: String = "building.2"
    @State private var selectedCategory: String = "All"
    
    struct DepartmentIcon: Identifiable {
        let id = UUID()
        let icon: String
    }
    
    struct BusinessSection: Identifiable {
        let id = UUID()
        let title: String
        let icons: [DepartmentIcon]
    }
    
    let categories = ["All", "Health", "Technology", "Education", "Tourism", 
                     "Food", "Energy", "Fashion", "Entertainment", 
                     "Transport", "Real Estate", "Finance", "E-Commerce", 
                     "Consulting"]
    
    let sections = [
        BusinessSection(title: "Health", icons: [
            "heart", "waveform.path.ecg", "stethoscope", "cross", "pills", 
            "bandage", "staroflife", "thermometer", "bed.double", "lungs", 
            "ear", "eye", "brain.head.profile", "hand.raised", "figure.walk", 
            "drop", "allergens", "bolt.heart", "person.crop.circle.badge.checkmark", 
            "plus.circle"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Technology", icons: [
            "desktopcomputer", "laptopcomputer", "iphone", "ipad", "cpu", 
            "server.rack", "network", "antenna.radiowaves.left.and.right", "wifi", "gear",
            "cloud", "bolt.circle", "battery.100", "keyboard", "printer", 
            "camera", "mic", "speaker.wave.2", "cpu", "arrow.up.bin"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Education", icons: [
            "book", "graduationcap", "applelogo", "pencil", "folder",
            "text.book.closed", "calendar", "magnifyingglass", "square.and.pencil", "bookmark",
            "doc", "person.crop.rectangle", "ruler", "paintbrush", "brain",
            "character.book.closed", "brain.head.profile", "list.bullet.rectangle", "quote.bubble", "highlighter"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Tourism", icons: [
            "airplane", "suitcase", "globe", "map", "tent",
            "binoculars", "camera", "sun.max", "mountain.2", "beach.umbrella",
            "leaf", "train.side.front.car", "car", "bus", "signpost.right",
            "house", "star", "creditcard", "location.circle", "location"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Food", icons: [
            "fork.knife", "cup.and.saucer", "leaf", "cart", "bag",
            "takeoutbag.and.cup.and.straw", "basket", "fork.knife.circle", "wineglass", "birthday.cake",
            "carrot", "tortoise", "leaf.circle", "leaf.circle", "fork.knife.circle",
            "cup.and.saucer", "fish", "fork.knife.circle", "fork.knife.circle", "flame"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Energy", icons: [
            "bolt", "leaf", "flame", "drop", "wind",
            "globe", "sun.max", "fuelpump", "mountain.2", "tree",
            "car.2", "battery.100", "lightbulb", "fanblades", "trash",
            "arrow.3.trianglepath", "bolt.shield", "hammer", "building.columns", "gearshape"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Fashion", icons: [
            "scissors", "hanger", "tag", "bag", "tshirt",
            "tshirt", "bag", "circle.grid.cross", "clock", "rectangle.split.3x3",
            "arrow.2.squarepath", "scissors.circle", "circle.grid.2x2", "circle.grid.cross", "wand.and.stars",
            "cube.box", "sparkles", "star.circle", "basket", "globe"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Entertainment", icons: [
            "play.circle", "film", "music.note", "gamecontroller", "mic",
            "headphones", "tv", "camera", "film", "video",
            "speaker.wave.2", "theatermasks", "lightbulb", "paintpalette", "book",
            "star", "bolt", "record.circle", "play.rectangle", "popcorn"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Transport", icons: [
            "car", "car.2", "bicycle", "airplane", "ferry",
            "train.side.front.car", "tram", "bus", "location", "globe",
            "arrow.up.doc", "square.and.arrow.up", "wrench.and.screwdriver", "fuelpump", "gear",
            "map", "house.circle", "calendar", "person.crop.rectangle", "arrow.triangle.turn.up.right.diamond"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Real Estate", icons: [
            "house", "building.2", "magnifyingglass", "lock", "key",
            "calendar", "dollarsign.circle", "pencil", "folder", "gear",
            "location", "creditcard", "person.crop.circle.badge.checkmark", "lightbulb", "list.bullet",
            "map", "signpost.right", "doc.text", "bookmark", "hand.raised"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Finance", icons: [
            "chart.bar", "dollarsign.circle", "creditcard", "lock", "key",
            "banknote", "building.columns", "doc.text", "checkmark", "wallet.pass",
            "list.bullet.rectangle", "arrow.triangle.2.circlepath.circle", "shield", "magnifyingglass", "tag",
            "calendar", "chart.pie", "lock.doc", "person.crop.circle.badge.checkmark", "text.badge.checkmark"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "E-Commerce", icons: [
            "cart", "bag", "creditcard", "house", "car.2",
            "globe", "tag", "barcode", "barcode.viewfinder", "phone.arrow.down.left",
            "arrow.triangle.2.circlepath", "clock.arrow.circlepath", "wallet.pass", "gift", "bookmark",
            "cube.box", "calendar", "magnifyingglass", "bell", "bolt"
        ].map { DepartmentIcon(icon: $0) }),
        
        BusinessSection(title: "Consulting", icons: [
            "briefcase", "doc.text.magnifyingglass", "chart.bar", "calendar", "lightbulb",
            "network", "person.crop.rectangle", "gear", "arrow.3.trianglepath", "quote.bubble",
            "list.bullet.rectangle", "building.2", "key", "lock", "hand.raised",
            "arrow.uturn.forward.circle", "brain", "checkmark", "chart.pie", "doc"
        ].map { DepartmentIcon(icon: $0) })
    ]
    
    var filteredSections: [BusinessSection] {
        if selectedCategory == "All" {
            return sections
        }
        return sections.filter { $0.title == selectedCategory }
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
                .background(Color(UIColor.systemBackground))
                
                // Contenido principal
                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                        ForEach(filteredSections) { section in
                            Section {
                                LazyVGrid(
                                    columns: [
                                        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(section.icons) { item in
                                        IconCell(
                                            icon: item.icon,
                                            isSelected: selectedIcon == item.icon,
                                            action: {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                selectedIcon = item.icon
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            } header: {
                                HStack {
                                    Text(section.title)
                                        .font(.headline)
                                        .padding(.leading)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .background(Color(UIColor.systemBackground))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Icon")
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
                    Button("Done") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        updateIcon(to: selectedIcon)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getCurrentIcon() -> String {
        let dictionary = (try? JSONDecoder().decode([String: String].self, from: Data(iconStorage.utf8))) ?? [:]
        return dictionary[departmentName] ?? "building.2"
    }
    
    private func updateIcon(to newIcon: String) {
        var dictionary = (try? JSONDecoder().decode([String: String].self, from: Data(iconStorage.utf8))) ?? [:]
        dictionary[departmentName] = newIcon
        if let encoded = try? JSONEncoder().encode(dictionary),
           let string = String(data: encoded, encoding: .utf8) {
            iconStorage = string
        }
    }
}

// Componente separado para la celda del icono
struct IconCell: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
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
            
            Text(icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32)
        }
        .frame(width: 80, height: 100)
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
