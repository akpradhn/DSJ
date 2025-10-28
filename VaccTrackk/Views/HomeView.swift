import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm: PatientListViewModel
    @State private var showingNewPatient = false

    init() {
        let context = PersistenceController.shared.viewContext
        _vm = StateObject(wrappedValue: PatientListViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.patients, id: \.objectID) { patient in
                    NavigationLink {
                        PatientDetailView(patient: patient)
                    } label: {
                        PatientRowView(patient: patient)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            vm.delete(patient)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search patients"))
            .navigationTitle(Text("VaccTrack"))
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingNewPatient = true
                    } label: {
                        Label("New Patient", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewPatient) {
                NavigationStack {
                    PatientFormView(onSaved: { _ in
                        vm.fetch()
                        showingNewPatient = false
                    }, onCancel: {
                        showingNewPatient = false
                    })
                    .environment(\.managedObjectContext, context)
                }
            }
            .onAppear { vm.fetch() }
        }
    }
}


