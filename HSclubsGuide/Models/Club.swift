import Foundation

/// A single club as surfaced on a school's public discovery mini-site.
/// This is read-only discovery data; it never represents memberships or applications.
struct Club: Decodable, Identifiable, Sendable, Equatable, Hashable {
    let id: Int
    let name: String
    let category: String
    let advisor: String?
    let location: String?        // Room number or name where the club meets.
    let meetingSchedule: String?
    let description: String
    let instagramUrl: URL?
}

/// The contract payload for a single school's club directory fixture.
struct SchoolClubsResponse: Decodable, Sendable {
    let schemaVersion: String
    let slug: String
    let generatedAt: Date
    let clubs: [Club]
}
