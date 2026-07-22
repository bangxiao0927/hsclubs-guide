import XCTest
@testable import HSclubsGuide

final class ContractDecoderTests: XCTestCase {
    func testValidDirectoryFixtureDecodes() throws {
        let response = try ContractDecoder.decodeDirectory(from: try fixture(named: "directory-schools.valid"))

        XCTAssertEqual(response.schemaVersion, "1.0")
        XCTAssertEqual(response.schools.count, 4)
        XCTAssertEqual(response.schools.first?.slug, "mountain-view")
    }

    func testPrivateFieldsAreRejected() throws {
        XCTAssertThrowsError(
            try ContractDecoder.decodeDirectory(from: try fixture(named: "directory-schools.invalid"))
        ) { error in
            XCTAssertEqual(error as? ContractError, .unknownFields(["ownerEmail"]))
        }
    }

    func testValidSourceSummaryDecodes() throws {
        let summary = try ContractDecoder.decodeSourceSummary(from: try fixture(named: "source-summary.valid"))

        XCTAssertEqual(summary.schemaVersion, "1.0")
        XCTAssertEqual(summary.clubCount, 42)
    }

    func testValidSchoolClubsFixtureDecodes() throws {
        let response = try ContractDecoder.decodeSchoolClubs(
            from: try fixture(named: "school-clubs.mountain-view.valid")
        )

        XCTAssertEqual(response.schemaVersion, "1.0")
        XCTAssertEqual(response.slug, "mountain-view")
        XCTAssertEqual(response.clubs.count, 18)
        XCTAssertEqual(response.clubs.first?.name, "Chess Club")
        XCTAssertEqual(response.clubs.first?.category, "Competition & Strategy")
    }

    func testSchoolClubsRejectsUnknownClubFields() throws {
        let json = """
        {
          "schemaVersion": "1.0",
          "slug": "mountain-view",
          "generatedAt": "2026-07-19T20:20:00Z",
          "clubs": [
            { "id": 1, "name": "Chess Club", "category": "Strategy", "description": "Play.", "memberEmail": "secret@example.com" }
          ]
        }
        """
        XCTAssertThrowsError(try ContractDecoder.decodeSchoolClubs(from: Data(json.utf8))) { error in
            XCTAssertEqual(error as? ContractError, .unknownFields(["memberEmail"]))
        }
    }

    func testSchoolClubsRejectsInsecureInstagramURL() throws {
        let json = """
        {
          "schemaVersion": "1.0",
          "slug": "mountain-view",
          "generatedAt": "2026-07-19T20:20:00Z",
          "clubs": [
            { "id": 1, "name": "Chess Club", "category": "Strategy", "description": "Play.", "instagramUrl": "http://instagram.com/insecure" }
          ]
        }
        """
        XCTAssertThrowsError(try ContractDecoder.decodeSchoolClubs(from: Data(json.utf8)))
    }

    func testInvalidSourceSummaryAndPrivateFieldsAreRejected() throws {
        XCTAssertThrowsError(
            try ContractDecoder.decodeSourceSummary(from: try fixture(named: "source-summary.invalid"))
        ) { error in
            XCTAssertEqual(error as? ContractError, .unknownFields(["ownerEmail"]))
        }
    }

    func testHTTPOutboundURLIsRejected() throws {
        let data = try fixture(named: "source-summary.valid")
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        let insecure = Data(text.replacingOccurrences(of: "https://", with: "http://").utf8)

        XCTAssertThrowsError(try ContractDecoder.decodeSourceSummary(from: insecure))
    }

    private func fixture(named name: String) throws -> Data {
        let url = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
                ?? Bundle(for: Self.self).url(forResource: name, withExtension: "json")
        )
        return try Data(contentsOf: url)
    }
}
