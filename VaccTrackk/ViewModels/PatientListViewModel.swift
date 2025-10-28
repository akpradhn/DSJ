import Foundation
import CoreData
import Combine

final class PatientListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var patients: [Patient] = []

    private var cancellables = Set<AnyCancellable>()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context

        $searchText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetch()
            }
            .store(in: &cancellables)

        fetch()
    }

    func fetch() {
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        var predicates: [NSPredicate] = []
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            predicates.append(NSPredicate(format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", query, query))
        }
        request.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "firstName", ascending: true)
        ]
        do {
            patients = try context.fetch(request)
        } catch {
            print("Fetch patients failed: \(error)")
            patients = []
        }
    }

    func delete(_ patient: Patient) {
        context.delete(patient)
        do {
            try context.save()
            fetch()
        } catch {
            print("Delete patient failed: \(error)")
            context.rollback()
        }
    }
}


