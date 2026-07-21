import Foundation

struct DirectoryResponse: Decodable, Sendable {
    let schemaVersion: String
    let generatedAt: Date
    let schools: [School]
}

struct School: Decodable, Identifiable, Sendable {
    let slug: String
    let name: String
    let shortName: String
    let canonicalURL: URL
    let location: SchoolLocation
    let verificationStatus: String
    let availability: SchoolAvailability
    let clubCount: Int?
    let categories: [String: Int]
    let sourceUpdatedAt: Date?
    let lastSuccessfulCollectionAt: Date?

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug, name, shortName, location, verificationStatus, availability, clubCount
        case categories, sourceUpdatedAt, lastSuccessfulCollectionAt
        case canonicalURL = "canonicalUrl"
    }
}

struct SchoolLocation: Decodable, Sendable {
    let city: String
    let region: String
    let country: String

    var displayName: String { "\(city), \(region)" }
}

enum SchoolAvailability: String, Decodable, Sendable {
    case fresh
    case stale
    case unavailable
    case suspended

    var label: String {
        switch self {
        case .fresh: "Current"
        case .stale: "Update delayed"
        case .unavailable: "Temporarily unavailable"
        case .suspended: "Listing suspended"
        }
    }
}

struct SourceSummary: Decodable, Sendable {
    let schemaVersion: String
    let schoolName: String
    let shortName: String
    let slug: String
    let canonicalURL: URL
    let status: String
    let clubCount: Int
    let categories: [String: Int]
    let memberCount: Int?
    let lastUpdatedAt: Date?
    let generatedAt: Date
    let dataHash: String

    enum CodingKeys: String, CodingKey {
        case schemaVersion, schoolName, shortName, slug, status, clubCount, categories
        case memberCount, lastUpdatedAt, generatedAt, dataHash
        case canonicalURL = "canonicalUrl"
    }
}
