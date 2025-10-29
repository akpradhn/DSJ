import SwiftUI
import PhotosUI
import UIKit

struct DoseDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: DoseViewModel
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isGiven: Bool = false
    @State private var showLibrary: Bool = false

    init(dose: Dose) {
        _vm = StateObject(wrappedValue: DoseViewModel(context: PersistenceController.shared.viewContext, dose: dose, patientDOB: dose.patient?.dob ?? Date()))
        _isGiven = State(initialValue: dose.givenOn != nil)
    }

    var body: some View {
        Form {
            Section(header: Text("Vaccine")) {
                Text(vm.dose.vaccine?.name ?? "-")
                TextField("Vaccine Brand", text: $vm.vaccineBrand)
                TextField("Batch Number", text: $vm.batchNumber)
            }
            Section(header: Text("Scheduling")) {
                DatePicker("Scheduled Date", selection: $vm.scheduledDate, in: (vm.dose.patient?.dob ?? Date.distantPast)...Date.distantFuture, displayedComponents: .date)

                Toggle("Given", isOn: $isGiven)
                    .onChange(of: isGiven) { _, newValue in
                        if newValue {
                            if vm.givenOn == nil { vm.givenOn = Date() }
                        } else {
                            vm.givenOn = nil
                        }
                    }

                if isGiven {
                    DatePicker("Given On", selection: Binding(get: {
                        vm.givenOn ?? Date()
                    }, set: { newVal in
                        vm.givenOn = newVal
                    }), in: (vm.dose.patient?.dob ?? Date.distantPast)...Date.distantFuture, displayedComponents: .date)
                } else {
                    HStack {
                        Text("Given On")
                        Spacer()
                        Text("Not set").foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }

                HStack {
                    Text("Status")
                    Spacer()
                    Text(currentStatusText).foregroundColor(currentStatusColor)
                }
            }
            Section(header: Text("Physical Measurements")) {
                HStack {
                    Text("Weight (g)")
                    Spacer()
                    TextField("0", value: $vm.weightAtDose, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Height (cm)")
                    Spacer()
                    TextField("0", value: $vm.heightAtDose, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Head Circumference (cm)")
                    Spacer()
                    TextField("0", value: $vm.headCircumferenceAtDose, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section(header: Text("Details")) {
                TextField("Facility", text: $vm.facility)
                TextField("Administered By", text: $vm.administeredBy)
                TextEditor(text: $vm.notes)
                    .frame(minHeight: 80)
            }
            Section(header: Text("Attachment")) {
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 160)
                        if let img = vm.photoImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.secondary)
                                Text("Add a photo (optional)")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        Button {
                            showLibrary = true
                        } label: {
                            Label("Choose Photo", systemImage: "photo")
                        }
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Dose", systemImage: "trash")
                }
            }
        }
        .navigationTitle(Text("Dose Details"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        try vm.save()
                        dismiss()
                    } catch let error as NSError {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
        }
        .alert("Delete Dose?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                do {
                    try vm.delete()
                    dismiss()
                } catch let error as NSError {
                    errorMessage = "Failed to delete dose: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete this dose record.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showLibrary, onDismiss: { showLibrary = false }) {
            PhotoLibraryPickerView(image: Binding(get: { vm.photoImage }, set: { vm.photoImage = $0 }))
        }
    }

    private var currentStatusText: String {
        if let given = vm.givenOn { return "Given (" + DateHelpers.shortDate(given) + ")" }
        let now = Date()
        let scheduled = vm.scheduledDate
        if scheduled > now {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now), to: Calendar.current.startOfDay(for: scheduled)).day ?? 0
            return days == 0 ? "Due" : "Upcoming (\(max(days, 0)) days)"
        } else {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: scheduled), to: Calendar.current.startOfDay(for: now)).day ?? 0
            return days > 0 ? "Overdue (\(days))" : "Due"
        }
    }

    private var currentStatusColor: Color {
        if vm.givenOn != nil { return .green }
        let now = Date()
        let scheduled = vm.scheduledDate
        if scheduled > now { return .yellow }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: scheduled), to: Calendar.current.startOfDay(for: now)).day ?? 0
        return days > 0 ? .red : .yellow
    }
}

// PHPicker-based library picker (guaranteed photo library UI)
struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPickerView
        init(_ parent: PhotoLibraryPickerView) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            defer { picker.dismiss(animated: true) }
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { obj, _ in
                    if let ui = obj as? UIImage { DispatchQueue.main.async { self.parent.image = ui } }
                }
            }
        }
    }
}


