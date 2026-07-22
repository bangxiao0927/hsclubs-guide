import XCTest

@MainActor
final class DiscoveryFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSearchOpensSchoolClubDirectory() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--use-fixture-directory"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Find your school's club directory."].waitForExistence(timeout: 5))
        app.searchFields["School, city, or region"].tap()
        app.searchFields["School, city, or region"].typeText("MVHS")

        let card = app.buttons["school-card-mountain-view"]
        XCTAssertTrue(card.waitForExistence(timeout: 2))
        card.tap()

        // The per-school club directory should load with its search field and real clubs.
        let clubSearch = app.textFields["club-search"]
        XCTAssertTrue(clubSearch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Chess Club"].waitForExistence(timeout: 5))
    }
}
