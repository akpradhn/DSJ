import SwiftUI
import CoreData

struct PatientFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: PatientViewModel

    // Local state for time picker, mirrors vm.timeOfBirth (stored as user string)
    @State private var timePickerDate: Date = Date()

    // Units
    @State private var weightUnit: String = "g" // g or kg
    @State private var lengthUnit: String = "cm" // cm or in
    @State private var headUnit: String = "cm"   // cm or in

    // Mode of delivery selection
    private let deliveryOptions: [String] = [
        "Normal (Vaginal) Delivery",
        "Induced Delivery",
        "Assisted Delivery (Forceps / Vacuum)",
        "Cesarean Section (C-Section)",
        "VBAC (Vaginal Birth After Cesarean)",
        "Water Birth",
        "Home Birth",
        "Lotus Birth",
        "Other"
    ]
    @State private var selectedDelivery: String = ""
    @State private var otherDelivery: String = ""

    // Editable numeric inputs (as strings) to allow manual entry
    @State private var weightInput: String = ""
    @State private var lengthInput: String = ""
    @State private var headInput: String = ""

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

                // Birth time: hour & minute picker bound to a local Date that writes to vm.timeOfBirth string
                DatePicker("Time of Birth", selection: Binding(get: {
                    timePickerDate
                }, set: { newVal in
                    timePickerDate = newVal
                    vm.timeOfBirth = Self.timeFormatter.string(from: newVal)
                }), displayedComponents: .hourAndMinute)
                .onAppear {
                    let existing = vm.timeOfBirth
                    if !existing.isEmpty, let parsed = Self.timeFormatter.date(from: existing) {
                        timePickerDate = parsed
                    }
                }

                // Mode of delivery with Other option
                Picker("Mode of Delivery", selection: $selectedDelivery) {
                    ForEach(deliveryOptions, id: \.self) { Text($0).tag($0) }
                }
                if selectedDelivery == "Other" {
                    TextField("Specify delivery details", text: $otherDelivery)
                }

                // Birth weight with unit toggle, editable numeric field and stepper
                VStack(alignment: .leading) {
                    HStack {
                        Text("Birth Weight")
                        Spacer()
                        Picker("", selection: $weightUnit) {
                            Text("g").tag("g")
                            Text("kg").tag("kg")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    HStack(spacing: 16) {
                        TextField(weightUnit == "g" ? "grams" : "kilograms", text: $weightInput)
                            .keyboardType(.decimalPad)
                            .frame(width: 120)
                            .onChange(of: weightInput) { _, _ in updateWeightFromInput() }
                        Stepper("", value: weightBinding(), in: weightUnit == "g" ? 0...10000 : 0...100, step: 1)
                            .labelsHidden()
                            .frame(width: 160)
                    }
                }

                // Length with unit toggle, editable numeric field and stepper
                VStack(alignment: .leading) {
                    HStack {
                        Text("Length")
                        Spacer()
                        Picker("", selection: $lengthUnit) {
                            Text("cm").tag("cm")
                            Text("in").tag("in")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    HStack(spacing: 16) {
                        TextField(lengthUnit == "cm" ? "centimeters" : "inches", text: $lengthInput)
                            .keyboardType(.numberPad)
                            .frame(width: 120)
                            .onChange(of: lengthInput) { _, _ in updateLengthFromInput() }
                        Stepper("", value: lengthBinding(), in: 0...100, step: 1)
                            .labelsHidden()
                            .frame(width: 160)
                    }
                }

                // Head circumference input similar to height (no slider)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Head Circumference")
                        Spacer()
                        Picker("", selection: $headUnit) {
                            Text("cm").tag("cm")
                            Text("in").tag("in")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    HStack(spacing: 16) {
                        TextField(headUnit == "cm" ? "centimeters" : "inches", text: $headInput)
                            .keyboardType(.decimalPad)
                            .frame(width: 120)
                            .onChange(of: headInput) { _, _ in updateHeadFromInput() }
                        Stepper("", value: headBinding(), in: 0...60, step: 1)
                            .labelsHidden()
                            .frame(width: 160)
                    }
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
        .onAppear(perform: initFields)
        .navigationTitle(vm.patient == nil ? Text("New Patient") : Text("Edit Patient"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onCancel() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        guard vm.isValid else { return }
                        // persist chosen delivery
                        if selectedDelivery == "Other" { vm.modeOfDelivery = otherDelivery } else { vm.modeOfDelivery = selectedDelivery }
                        let saved = try vm.saveAndGenerateDosesIfNeeded()
                        onSaved(saved)
                    } catch {
                        // handle error
                    }
                }
                .disabled(!vm.isValid)
            }
        }
        .onChange(of: weightUnit) { _, _ in syncInputsFromModel() }
        .onChange(of: lengthUnit) { _, _ in syncInputsFromModel() }
        .onChange(of: headUnit) { _, _ in syncInputsFromModel() }
    }

    private func initFields() {
        initDelivery()
        syncInputsFromModel()
    }

    private func syncInputsFromModel() {
        // Birth weight
        if weightUnit == "g" {
            weightInput = String(vm.birthWeightGrams)
        } else {
            weightInput = String(format: "%.1f", Double(vm.birthWeightGrams)/1000.0)
        }
        // Length
        if lengthUnit == "cm" { lengthInput = String(vm.lengthCm) } else { lengthInput = String(Int(round(Double(vm.lengthCm)/2.54))) }
        // Head
        if headUnit == "cm" { headInput = String(format: "%.1f", vm.headCircumferenceCm) } else { headInput = String(format: "%.1f", Double(vm.headCircumferenceCm)/2.54) }
    }

    private func updateWeightFromInput() {
        if weightUnit == "g" {
            let v = Int(weightInput.filter({ $0.isNumber })) ?? vm.birthWeightGrams
            vm.birthWeightGrams = v
        } else {
            let v = Double(weightInput) ?? Double(vm.birthWeightGrams)/1000.0
            vm.birthWeightGrams = Int(round(v * 1000.0))
        }
    }

    private func updateLengthFromInput() {
        if lengthUnit == "cm" {
            let v = Int(lengthInput.filter({ $0.isNumber })) ?? vm.lengthCm
            vm.lengthCm = v
        } else {
            let v = Double(lengthInput) ?? Double(vm.lengthCm)/2.54
            vm.lengthCm = Int(round(v * 2.54))
        }
    }

    private func updateHeadFromInput() {
        if headUnit == "cm" {
            let v = Double(headInput) ?? Double(vm.headCircumferenceCm)
            vm.headCircumferenceCm = Float(v)
        } else {
            let v = Double(headInput) ?? Double(vm.headCircumferenceCm)/2.54
            vm.headCircumferenceCm = Float(v * 2.54)
        }
    }

    private func initDelivery() {
        // Initialize delivery selection to existing value or default
        if deliveryOptions.contains(vm.modeOfDelivery) {
            selectedDelivery = vm.modeOfDelivery
        } else if vm.modeOfDelivery.isEmpty {
            selectedDelivery = deliveryOptions.first ?? "Normal (Vaginal) Delivery"
        } else {
            selectedDelivery = "Other"
            otherDelivery = vm.modeOfDelivery
        }
    }

    // Bindings that convert between units and stored values
    private func weightBinding() -> Binding<Int> {
        if weightUnit == "g" {
            return Binding(get: { vm.birthWeightGrams }, set: { vm.birthWeightGrams = $0; syncInputsFromModel() })
        } else { // kg in deci-kg steps represented as Int
            return Binding(get: { Int(round(Double(vm.birthWeightGrams)/100.0)) }, set: { vm.birthWeightGrams = $0 * 100; syncInputsFromModel() })
        }
    }

    private func lengthBinding() -> Binding<Int> {
        if lengthUnit == "cm" {
            return Binding(get: { vm.lengthCm }, set: { vm.lengthCm = $0; syncInputsFromModel() })
        } else { // inches (approx)
            return Binding(get: { Int(round(Double(vm.lengthCm)/2.54)) }, set: { vm.lengthCm = Int(round(Double($0) * 2.54)); syncInputsFromModel() })
        }
    }

    private func headBinding() -> Binding<Int> {
        if headUnit == "cm" {
            return Binding(get: { Int(round(Double(vm.headCircumferenceCm))) }, set: { vm.headCircumferenceCm = Float($0); syncInputsFromModel() })
        } else { // inches
            return Binding(get: { Int(round(Double(vm.headCircumferenceCm)/2.54)) }, set: { vm.headCircumferenceCm = Float(Double($0) * 2.54); syncInputsFromModel() })
        }
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        return df
    }()
}


