import XCTest

final class DiscoveryFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSearchOpensSchoolDetail() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Find your school"].waitForExistence(timeout: 5))
        app.searchFields["School, city, or region"].tap()
        app.searchFields["School, city, or region"].typeText("MVHS")

        let card = app.buttons["school-card-mountain-view"]
        XCTAssertTrue(card.waitForExistence(timeout: 2))
        card.tap()
        XCTAssertTrue(app.links["open-school-site"].waitForExistence(timeout: 2))
    }
}
