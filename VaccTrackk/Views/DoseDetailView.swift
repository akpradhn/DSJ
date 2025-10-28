import SwiftUI

struct DoseDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: DoseViewModel

    init(dose: Dose) {
        _vm = StateObject(wrappedValue: DoseViewModel(context: PersistenceController.shared.viewContext, dose: dose, patientDOB: dose.patient?.dob ?? Date()))
    }

    var body: some View {
        Form {
            Section(header: Text("Vaccine")) {
                Text(vm.dose.vaccine?.name ?? "-")
            }
            Section(header: Text("Scheduling")) {
                DatePicker("Scheduled Date", selection: $vm.scheduledDate, displayedComponents: .date)
                DatePicker("Given On", selection: Binding($vm.givenOn, Date()), displayedComponents: .date)
            }
            Section(header: Text("Details")) {
                TextField("Batch Number", text: $vm.batchNumber)
                TextField("Facility", text: $vm.facility)
                TextField("Administered By", text: $vm.administeredBy)
                TextEditor(text: $vm.notes)
                    .frame(minHeight: 80)
            }
            Section {
                Button(role: .destructive) {
                    do {
                        try vm.delete()
                        dismiss()
                    } catch {
                    }
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
    }
}


