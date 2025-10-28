import SwiftUI
import CoreData

struct PatientFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: PatientViewModel

    let onSaved: (Patient) -> Void
    let onCancel: () -> Void

    init(patient: Patient? = nil,
         onSaved: @escaping (Patient) -> Void,
         onCancel: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: PatientViewModel(context: PersistenceController.shared.viewContext, patient: patient))
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    var body: some View {
        Form {
            Section(header: Text("Identity")) {
                TextField("First Name", text: $vm.firstName)
                TextField("Last Name", text: $vm.lastName)
                Picker("Gender", selection: $vm.gender) {
                    Text("Select").tag("")
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
            }
            Section(header: Text("Birth Details")) {
                DatePicker("Date of Birth", selection: $vm.dob, displayedComponents: .date)
                TextField("Time of Birth (e.g. 07:35 AM)", text: $vm.timeOfBirth)
                TextField("Mode of Delivery", text: $vm.modeOfDelivery)
                Stepper(value: $vm.birthWeightGrams, in: 0...10000, step: 10) {
                    HStack {
                        Text("Birth Weight")
                        Spacer()
                        Text(Formatters.grams(vm.birthWeightGrams))
                    }
                }
                Stepper(value: $vm.lengthCm, in: 0...100, step: 1) {
                    HStack {
                        Text("Length")
                        Spacer()
                        Text("\(vm.lengthCm) cm")
                    }
                }
                Slider(value: Binding(get: {
                    Double(vm.headCircumferenceCm)
                }, set: { vm.headCircumferenceCm = Float($0) }), in: 0...60, step: 0.5) {
                    Text("Head Circumference")
                }
                HStack {
                    Spacer()
                    Text(String(format: "%.1f cm", vm.headCircumferenceCm))
                    Spacer()
                }
            }
            Section(header: Text("Parents & Contact")) {
                TextField("Mother's Name", text: $vm.motherName)
                TextField("Father's Name", text: $vm.fatherName)
                TextField("Contact Number", text: $vm.contactNumber)
                    .keyboardType(.phonePad)
            }
            Section(header: Text("Notes")) {
                TextEditor(text: $vm.notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle(vm.patient == nil ? Text("New Patient") : Text("Edit Patient"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onCancel() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        guard vm.isValid else { return }
                        let saved = try vm.saveAndGenerateDosesIfNeeded()
                        onSaved(saved)
                    } catch {
                        // handle error
                    }
                }
                .disabled(!vm.isValid)
            }
        }
    }
}


