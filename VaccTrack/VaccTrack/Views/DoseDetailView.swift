import SwiftUI

struct DoseDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: DoseViewModel
    @State private var showDeleteConfirmation = false

    init(dose: Dose) {
        _vm = StateObject(wrappedValue: DoseViewModel(context: PersistenceController.shared.viewContext, dose: dose, patientDOB: dose.patient?.dob ?? Date()))
    }

    var body: some View {
        Form {
            Section(header: Text("Vaccine")) {
                Text(vm.dose.vaccine?.name ?? "-")
                TextField("Vaccine Brand", text: $vm.vaccineBrand)
                TextField("Batch Number", text: $vm.batchNumber)
            }
            Section(header: Text("Scheduling")) {
                DatePicker("Scheduled Date", selection: $vm.scheduledDate, displayedComponents: .date)
                DatePicker("Given On", selection: Binding(get: {
                    vm.givenOn ?? Date()
                }, set: { newVal in
                    vm.givenOn = newVal
                }), displayedComponents: .date)
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
                    } catch {
                    }
                }
            }
        }
        .alert("Delete Dose?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                do {
                    try vm.delete()
                    dismiss()
                } catch {
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete this dose record.")
        }
    }
}


