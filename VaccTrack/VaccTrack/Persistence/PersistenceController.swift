import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "VaccTrack", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func inMemoryController() -> PersistenceController {
        PersistenceController(inMemory: true)
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Patient
        let patient = NSEntityDescription()
        patient.name = "Patient"
        patient.managedObjectClassName = "Patient"

        let p_id = NSAttributeDescription()
        p_id.name = "id"
        p_id.attributeType = .UUIDAttributeType
        p_id.isOptional = false
        p_id.isIndexed = true

        let p_firstName = NSAttributeDescription()
        p_firstName.name = "firstName"
        p_firstName.attributeType = .stringAttributeType
        p_firstName.isOptional = false

        let p_lastName = NSAttributeDescription()
        p_lastName.name = "lastName"
        p_lastName.attributeType = .stringAttributeType
        p_lastName.isOptional = true

        let p_motherName = NSAttributeDescription()
        p_motherName.name = "motherName"
        p_motherName.attributeType = .stringAttributeType
        p_motherName.isOptional = true

        let p_fatherName = NSAttributeDescription()
        p_fatherName.name = "fatherName"
        p_fatherName.attributeType = .stringAttributeType
        p_fatherName.isOptional = true

        let p_gender = NSAttributeDescription()
        p_gender.name = "gender"
        p_gender.attributeType = .stringAttributeType
        p_gender.isOptional = true

        let p_dob = NSAttributeDescription()
        p_dob.name = "dob"
        p_dob.attributeType = .dateAttributeType
        p_dob.isOptional = false

        let p_timeOfBirth = NSAttributeDescription()
        p_timeOfBirth.name = "timeOfBirth"
        p_timeOfBirth.attributeType = .stringAttributeType
        p_timeOfBirth.isOptional = true

        let p_modeOfDelivery = NSAttributeDescription()
        p_modeOfDelivery.name = "modeOfDelivery"
        p_modeOfDelivery.attributeType = .stringAttributeType
        p_modeOfDelivery.isOptional = true

        let p_birthWeight = NSAttributeDescription()
        p_birthWeight.name = "birthWeightGrams"
        p_birthWeight.attributeType = .integer16AttributeType
        p_birthWeight.isOptional = false
        p_birthWeight.defaultValue = 0

        let p_length = NSAttributeDescription()
        p_length.name = "lengthCm"
        p_length.attributeType = .integer16AttributeType
        p_length.isOptional = false
        p_length.defaultValue = 0

        let p_head = NSAttributeDescription()
        p_head.name = "headCircumferenceCm"
        p_head.attributeType = .floatAttributeType
        p_head.isOptional = false
        p_head.defaultValue = 0.0

        let p_contact = NSAttributeDescription()
        p_contact.name = "contactNumber"
        p_contact.attributeType = .stringAttributeType
        p_contact.isOptional = true

        let p_notes = NSAttributeDescription()
        p_notes.name = "notes"
        p_notes.attributeType = .stringAttributeType
        p_notes.isOptional = true

        let p_createdAt = NSAttributeDescription()
        p_createdAt.name = "createdAt"
        p_createdAt.attributeType = .dateAttributeType
        p_createdAt.isOptional = false

        // Vaccine
        let vaccine = NSEntityDescription()
        vaccine.name = "Vaccine"
        vaccine.managedObjectClassName = "Vaccine"

        let v_id = NSAttributeDescription()
        v_id.name = "id"
        v_id.attributeType = .UUIDAttributeType
        v_id.isOptional = false
        v_id.isIndexed = true

        let v_name = NSAttributeDescription()
        v_name.name = "name"
        v_name.attributeType = .stringAttributeType
        v_name.isOptional = false
        v_name.isIndexed = true

        let v_age = NSAttributeDescription()
        v_age.name = "recommendedAgeInWeeks"
        v_age.attributeType = .integer16AttributeType
        v_age.isOptional = false
        v_age.defaultValue = 0

        let v_sequence = NSAttributeDescription()
        v_sequence.name = "sequence"
        v_sequence.attributeType = .integer16AttributeType
        v_sequence.isOptional = false
        v_sequence.defaultValue = 0

        let v_notes = NSAttributeDescription()
        v_notes.name = "notes"
        v_notes.attributeType = .stringAttributeType
        v_notes.isOptional = true

        // Dose
        let dose = NSEntityDescription()
        dose.name = "Dose"
        dose.managedObjectClassName = "Dose"

        let d_id = NSAttributeDescription()
        d_id.name = "id"
        d_id.attributeType = .UUIDAttributeType
        d_id.isOptional = false
        d_id.isIndexed = true

        let d_scheduled = NSAttributeDescription()
        d_scheduled.name = "scheduledDate"
        d_scheduled.attributeType = .dateAttributeType
        d_scheduled.isOptional = false

        let d_due = NSAttributeDescription()
        d_due.name = "dueDate"
        d_due.attributeType = .dateAttributeType
        d_due.isOptional = true

        let d_given = NSAttributeDescription()
        d_given.name = "givenOn"
        d_given.attributeType = .dateAttributeType
        d_given.isOptional = true

        let d_batch = NSAttributeDescription()
        d_batch.name = "batchNumber"
        d_batch.attributeType = .stringAttributeType
        d_batch.isOptional = true

        let d_facility = NSAttributeDescription()
        d_facility.name = "facility"
        d_facility.attributeType = .stringAttributeType
        d_facility.isOptional = true

        let d_admin = NSAttributeDescription()
        d_admin.name = "administeredBy"
        d_admin.attributeType = .stringAttributeType
        d_admin.isOptional = true

        let d_notes = NSAttributeDescription()
        d_notes.name = "notes"
        d_notes.attributeType = .stringAttributeType
        d_notes.isOptional = true

        let d_createdAt = NSAttributeDescription()
        d_createdAt.name = "createdAt"
        d_createdAt.attributeType = .dateAttributeType
        d_createdAt.isOptional = false

        // New fields for dose details
        let d_weightAtDose = NSAttributeDescription()
        d_weightAtDose.name = "weightAtDose"
        d_weightAtDose.attributeType = .floatAttributeType
        d_weightAtDose.isOptional = false
        d_weightAtDose.defaultValue = 0.0

        let d_heightAtDose = NSAttributeDescription()
        d_heightAtDose.name = "heightAtDose"
        d_heightAtDose.attributeType = .floatAttributeType
        d_heightAtDose.isOptional = false
        d_heightAtDose.defaultValue = 0.0

        let d_headCircumferenceAtDose = NSAttributeDescription()
        d_headCircumferenceAtDose.name = "headCircumferenceAtDose"
        d_headCircumferenceAtDose.attributeType = .floatAttributeType
        d_headCircumferenceAtDose.isOptional = false
        d_headCircumferenceAtDose.defaultValue = 0.0

        let d_vaccineBrand = NSAttributeDescription()
        d_vaccineBrand.name = "vaccineBrand"
        d_vaccineBrand.attributeType = .stringAttributeType
        d_vaccineBrand.isOptional = true

        // Relationships
        let r_dose_patient = NSRelationshipDescription()
        r_dose_patient.name = "patient"
        r_dose_patient.destinationEntity = patient
        r_dose_patient.minCount = 0
        r_dose_patient.maxCount = 1
        r_dose_patient.deleteRule = .nullifyDeleteRule

        let r_patient_doses = NSRelationshipDescription()
        r_patient_doses.name = "doses"
        r_patient_doses.destinationEntity = dose
        r_patient_doses.minCount = 0
        r_patient_doses.maxCount = 0
        r_patient_doses.deleteRule = .cascadeDeleteRule

        r_dose_patient.inverseRelationship = r_patient_doses
        r_patient_doses.inverseRelationship = r_dose_patient

        let r_dose_vaccine = NSRelationshipDescription()
        r_dose_vaccine.name = "vaccine"
        r_dose_vaccine.destinationEntity = vaccine
        r_dose_vaccine.minCount = 0
        r_dose_vaccine.maxCount = 1
        r_dose_vaccine.deleteRule = .nullifyDeleteRule

        let r_vaccine_doses = NSRelationshipDescription()
        r_vaccine_doses.name = "doses"
        r_vaccine_doses.destinationEntity = dose
        r_vaccine_doses.minCount = 0
        r_vaccine_doses.maxCount = 0
        r_vaccine_doses.deleteRule = .cascadeDeleteRule

        r_dose_vaccine.inverseRelationship = r_vaccine_doses
        r_vaccine_doses.inverseRelationship = r_dose_vaccine

        patient.properties = [
            p_id, p_firstName, p_lastName, p_motherName, p_fatherName, p_gender, p_dob,
            p_timeOfBirth, p_modeOfDelivery, p_birthWeight, p_length, p_head, p_contact,
            p_notes, p_createdAt, r_patient_doses
        ]

        vaccine.properties = [v_id, v_name, v_age, v_sequence, v_notes, r_vaccine_doses]

        dose.properties = [
            d_id, d_scheduled, d_due, d_given, d_batch, d_facility, d_admin, d_notes, d_createdAt,
            d_weightAtDose, d_heightAtDose, d_headCircumferenceAtDose, d_vaccineBrand,
            r_dose_patient, r_dose_vaccine
        ]

        patient.uniquenessConstraints = [["id"]]
        vaccine.uniquenessConstraints = [["id"]]
        dose.uniquenessConstraints = [["id"]]

        model.entities = [patient, vaccine, dose]
        return model
    }
}


