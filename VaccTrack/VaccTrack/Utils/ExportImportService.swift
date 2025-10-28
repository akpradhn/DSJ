import Foundation
import CoreData

enum ExportImportService {
    static func exportAllPatientsJSON(context: NSManagedObjectContext) throws -> Data {
        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        let patients = try context.fetch(req)
        let payload = patients.map { PatientDTO(from: $0) }
        let data = try JSONEncoder.prettyEncoder.encode(payload)
        return data
    }

    static func exportPatientAsJSON(patient: Patient) throws -> Data {
        let dto = PatientDTO(from: patient)
        return try JSONEncoder.prettyEncoder.encode(dto)
    }

    static func importJSON(from url: URL, context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        try importData(data, context: context)
    }

    static func importData(_ data: Data, context: NSManagedObjectContext) throws {
        if let array = try? JSONDecoder.isoDecoder.decode([PatientDTO].self, from: data) {
            try merge(patients: array, context: context)
        } else {
            let single = try JSONDecoder.isoDecoder.decode(PatientDTO.self, from: data)
            try merge(patients: [single], context: context)
        }
    }

    private static func merge(patients dtos: [PatientDTO], context: NSManagedObjectContext) throws {
        try context.performAndWait {
            for dto in dtos {
                let patient = fetchPatient(id: dto.id, context: context) ?? Patient(context: context)
                patient.id = dto.id
                patient.createdAt = dto.createdAt
                if !dto.firstName.trimmingCharacters(in: .whitespaces).isEmpty { patient.firstName = dto.firstName }
                patient.lastName = dto.lastName
                patient.motherName = dto.motherName
                patient.fatherName = dto.fatherName
                patient.gender = dto.gender
                patient.dob = dto.dob
                patient.timeOfBirth = dto.timeOfBirth
                patient.modeOfDelivery = dto.modeOfDelivery
                patient.birthWeightGrams = Int16(dto.birthWeightGrams)
                patient.lengthCm = Int16(dto.lengthCm)
                patient.headCircumferenceCm = dto.headCircumferenceCm
                patient.contactNumber = dto.contactNumber
                patient.notes = dto.notes

                let existingDoseById: [UUID: Dose] = Dictionary(uniqueKeysWithValues: (patient.doses ?? []).map { ($0.id, $0) })
                for d in dto.doses {
                    let dose = existingDoseById[d.id] ?? Dose(context: context)
                    dose.id = d.id
                    dose.scheduledDate = d.scheduledDate
                    dose.dueDate = d.dueDate
                    dose.givenOn = d.givenOn
                    dose.batchNumber = d.batchNumber
                    dose.facility = d.facility
                    dose.administeredBy = d.administeredBy
                    dose.notes = d.notes
                    dose.createdAt = d.createdAt
                    dose.patient = patient

                    if let vaccineId = d.vaccine?.id {
                        let vaccine = fetchVaccine(id: vaccineId, context: context) ?? Vaccine(context: context)
                        vaccine.id = vaccineId
                        vaccine.name = d.vaccine?.name ?? vaccine.name
                        vaccine.recommendedAgeInWeeks = Int16(d.vaccine?.recommendedAgeInWeeks ?? Int(vaccine.recommendedAgeInWeeks))
                        vaccine.sequence = Int16(d.vaccine?.sequence ?? Int(vaccine.sequence))
                        vaccine.notes = d.vaccine?.notes
                        dose.vaccine = vaccine
                    } else if let name = d.vaccine?.name {
                        let vaccine = fetchVaccine(name: name, context: context) ?? Vaccine(context: context)
                        if vaccine.id == UUID() { vaccine.id = UUID() }
                        vaccine.name = name
                        vaccine.recommendedAgeInWeeks = Int16(d.vaccine?.recommendedAgeInWeeks ?? Int(vaccine.recommendedAgeInWeeks))
                        vaccine.sequence = Int16(d.vaccine?.sequence ?? Int(vaccine.sequence))
                        vaccine.notes = d.vaccine?.notes
                        dose.vaccine = vaccine
                    }
                }
            }
            try context.save()
        }
    }

    private static func fetchPatient(id: UUID, context: NSManagedObjectContext) -> Patient? {
        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    private static func fetchVaccine(id: UUID, context: NSManagedObjectContext) -> Vaccine? {
        let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    private static func fetchVaccine(name: String, context: NSManagedObjectContext) -> Vaccine? {
        let req: NSFetchRequest<Vaccine> = Vaccine.fetchRequest()
        req.predicate = NSPredicate(format: "name ==[cd] %@", name)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }
}

// MARK: - DTOs

struct PatientDTO: Codable, Equatable {
    var id: UUID
    var firstName: String
    var lastName: String?
    var motherName: String?
    var fatherName: String?
    var gender: String?
    var dob: Date
    var timeOfBirth: String?
    var modeOfDelivery: String?
    var birthWeightGrams: Int
    var lengthCm: Int
    var headCircumferenceCm: Float
    var contactNumber: String?
    var notes: String?
    var createdAt: Date
    var doses: [DoseDTO]

    init(from patient: Patient) {
        id = patient.id
        firstName = patient.firstName
        lastName = patient.lastName
        motherName = patient.motherName
        fatherName = patient.fatherName
        gender = patient.gender
        dob = patient.dob
        timeOfBirth = patient.timeOfBirth
        modeOfDelivery = patient.modeOfDelivery
        birthWeightGrams = Int(patient.birthWeightGrams)
        lengthCm = Int(patient.lengthCm)
        headCircumferenceCm = patient.headCircumferenceCm
        contactNumber = patient.contactNumber
        notes = patient.notes
        createdAt = patient.createdAt
        doses = patient.sortedDoses.map { DoseDTO(from: $0) }
    }
}

struct DoseDTO: Codable, Equatable {
    struct VaccineRef: Codable, Equatable {
        var id: UUID?
        var name: String
        var recommendedAgeInWeeks: Int
        var sequence: Int
        var notes: String?
    }
    var id: UUID
    var scheduledDate: Date
    var dueDate: Date?
    var givenOn: Date?
    var batchNumber: String?
    var facility: String?
    var administeredBy: String?
    var notes: String?
    var createdAt: Date
    var vaccine: VaccineRef?

    init(from dose: Dose) {
        id = dose.id
        scheduledDate = dose.scheduledDate
        dueDate = dose.dueDate
        givenOn = dose.givenOn
        batchNumber = dose.batchNumber
        facility = dose.facility
        administeredBy = dose.administeredBy
        notes = dose.notes
        createdAt = dose.createdAt
        if let v = dose.vaccine {
            vaccine = VaccineRef(id: v.id, name: v.name, recommendedAgeInWeeks: Int(v.recommendedAgeInWeeks), sequence: Int(v.sequence), notes: v.notes)
        } else {
            vaccine = nil
        }
    }
}

extension JSONEncoder {
    static var prettyEncoder: JSONEncoder {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return enc
    }
}

extension JSONDecoder {
    static var isoDecoder: JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }
}

extension Data {
    func tempFileURL(filename: String) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? self.write(to: url)
        return url
    }
}


