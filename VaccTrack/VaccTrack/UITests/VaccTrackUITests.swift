#if canImport(XCTest)
import XCTest

final class VaccTrackUITests: XCTestCase {
    func testCreatePatientAndMarkDoseGiven() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["New Patient"].tap()

        let firstName = app.textFields["First Name"]
        XCTAssertTrue(firstName.waitForExistence(timeout: 3))
        firstName.tap()
        firstName.typeText("UI Test")

        app.navigationBars.buttons["Save"].tap()

        app.cells.firstMatch.tap()

        let firstDose = app.cells.firstMatch
        if firstDose.exists {
            firstDose.swipeRight()
            app.buttons["Mark Given"].tap()
            app.navigationBars.buttons["Save"].tap()
        }
    }
}
#endif
