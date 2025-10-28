import XCTest
import CoreData
@testable import VaccTrack

final class SchedulingTests: XCTestCase {
    func testScheduledDatesWeeks() {
        let df = ISO8601DateFormatter()
        let dob = df.date(from: "2023-01-01T00:00:00Z")!
        let w0 = DateHelpers.scheduledDate(dob: dob, weeks: 0)
        let w6 = DateHelpers.scheduledDate(dob: dob, weeks: 6)
        let w10 = DateHelpers.scheduledDate(dob: dob, weeks: 10)
        XCTAssertEqual(Calendar.current.dateComponents([.day], from: dob, to: w0).day, 0)
        XCTAssertEqual(Calendar.current.dateComponents([.day], from: dob, to: w6).day, 42)
        XCTAssertEqual(Calendar.current.dateComponents([.day], from: dob, to: w10).day, 70)
    }

    func testLeapYearAndDST() {
        let df = ISO8601DateFormatter()
        let dob = df.date(from: "2024-02-28T00:00:00Z")!
        let w1 = DateHelpers.scheduledDate(dob: dob, weeks: 1)
        XCTAssertNotNil(w1)
        XCTAssertTrue(w1 > dob)
    }
}

final class PersistenceTests: XCTestCase {
    func testCreatePatientGenerateAndMarkDose() throws {
        let pc = PersistenceController(inMemory: true)
        let ctx = pc.viewContext

        let v = Vaccine(context: ctx)
        v.id = UUID()
        v.name = "TestVax"
        v.recommendedAgeInWeeks = 6
        v.sequence = 0

        let vm = PatientViewModel(context: ctx)
        vm.firstName = "Test"
        vm.dob = Date(timeIntervalSince1970: 0)
        let patient = try vm.saveAndGenerateDosesIfNeeded()

        XCTAssertFalse(patient.sortedDoses.isEmpty)

        let dose = try XCTUnwrap(patient.sortedDoses.first)
        XCTAssertNil(dose.givenOn)

        dose.givenOn = Date()
        try ctx.save()

        let req: NSFetchRequest<Dose> = Dose.fetchRequest()
        let doses = try ctx.fetch(req)
        XCTAssertEqual(doses.count, 1)
        XCTAssertNotNil(doses.first?.givenOn)
    }
}

final class ImportExportTests: XCTestCase {
    func testExportImportRoundtrip() throws {
        let pc = PersistenceController(inMemory: true)
        let ctx = pc.viewContext

        let v = Vaccine(context: ctx)
        v.id = UUID()
        v.name = "RoundtripVax"
        v.recommendedAgeInWeeks = 6
        v.sequence = 0

        let p = Patient(context: ctx)
        p.id = UUID()
        p.firstName = "Round"
        p.dob = Date()
        p.createdAt = Date()

        let d = Dose(context: ctx)
        d.id = UUID()
        d.scheduledDate = Date()
        d.createdAt = Date()
        d.patient = p
        d.vaccine = v

        try ctx.save()

        let data = try ExportImportService.exportPatientAsJSON(patient: p)

        let pc2 = PersistenceController(inMemory: true)
        try ExportImportService.importData(data, context: pc2.viewContext)

        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        let imported = try pc2.viewContext.fetch(req)
        XCTAssertEqual(imported.count, 1)
        XCTAssertEqual(imported.first?.firstName, "Round")
        XCTAssertEqual(imported.first?.sortedDoses.count, 1)
    }
}
