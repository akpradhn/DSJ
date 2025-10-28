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
        TabView {
            NavigationStack {
                VStack {
                    List {
                        Section {
                            HStack {
                                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                                TextField("Search patients...", text: $vm.searchText)
                            }
                        }
                        .listRowSeparator(.hidden)

                        ForEach(vm.patients, id: \.objectID) { patient in
                            NavigationLink { PatientDetailView(patient: patient) } label: { patientTile(patient) }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                .navigationTitle(Branding.appName)
                .overlay(alignment: .bottomTrailing) { Button(action: { showingNewPatient = true }) { Image(systemName: "plus").font(.system(size: 28, weight: .bold)).foregroundColor(.white).frame(width: 64, height: 64).background(Circle().fill(Color.blue)).shadow(radius: 4).padding() }.accessibilityLabel("Add Patient") }
            }
            .tabItem { Label("Patients", systemImage: "person.2.fill") }

            NavigationStack { SettingsView().navigationTitle("Settings") }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .sheet(isPresented: $showingNewPatient) { NavigationStack { PatientFormView(onSaved: { _ in vm.fetch(); showingNewPatient = false }, onCancel: { showingNewPatient = false }).environment(\.managedObjectContext, context) } }
        .onAppear { vm.fetch() }
    }

    private func patientTile(_ p: Patient) -> some View {
        HStack(spacing: 16) {
            ZStack { Circle().fill(Color.blue.opacity(0.15)).frame(width: 56, height: 56); Branding.appLogo.resizable().scaledToFit().frame(width: 28, height: 28).foregroundColor(.blue) }
            VStack(alignment: .leading, spacing: 2) { Text(p.displayName).font(.headline); Text("Born: \(DateHelpers.formatDate(p.dob))").font(.subheadline).foregroundColor(.secondary) }
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}


