import Foundation

enum ContractError: Error, Equatable, LocalizedError {
    case invalidJSON
    case invalidField(String)
    case unknownFields([String])

    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            "The directory returned unreadable data."
        case let .invalidField(field):
            "The directory returned an invalid \(field) value."
        case let .unknownFields(fields):
            "The directory returned undeclared fields: \(fields.joined(separator: ", "))."
        }
    }
}

enum ContractDecoder {
    private static let listKeys: Set<String> = ["schemaVersion", "generatedAt", "schools"]
    private static let schoolKeys: Set<String> = [
        "slug", "name", "shortName", "canonicalUrl", "location", "verificationStatus",
        "availability", "clubCount", "categories", "sourceUpdatedAt",
        "lastSuccessfulCollectionAt",
    ]
    private static let locationKeys: Set<String> = ["city", "region", "country"]
    private static let sourceKeys: Set<String> = [
        "schemaVersion", "schoolName", "shortName", "slug", "canonicalUrl", "status",
        "clubCount", "categories", "memberCount", "lastUpdatedAt", "generatedAt", "dataHash",
    ]

    static func decodeDirectory(from data: Data) throws -> DirectoryResponse {
        let object = try jsonObject(from: data)
        let root = try dictionary(object)
        try rejectUnknownKeys(in: root, allowing: listKeys)

        guard let schools = root["schools"] as? [Any] else {
            throw ContractError.invalidField("schools")
        }
        for item in schools {
            let school = try dictionary(item)
            try rejectUnknownKeys(in: school, allowing: schoolKeys)
            try rejectUnknownKeys(in: try dictionary(school["location"]), allowing: locationKeys)
        }

        let response = try decoder().decode(DirectoryResponse.self, from: data)
        try validate(response)
        return response
    }

    static func decodeSourceSummary(from data: Data) throws -> SourceSummary {
        let root = try dictionary(try jsonObject(from: data))
        try rejectUnknownKeys(in: root, allowing: sourceKeys)
        let summary = try decoder().decode(SourceSummary.self, from: data)

        guard summary.schemaVersion.hasPrefix("1."), summary.clubCount >= 0 else {
            throw ContractError.invalidField("source summary")
        }
        try validateHTTPS(summary.canonicalURL)
        guard summary.dataHash.range(of: "^[a-f0-9]{64}$", options: .regularExpression) != nil else {
            throw ContractError.invalidField("dataHash")
        }
        guard summary.categories.values.allSatisfy({ $0 >= 0 }),
              summary.categories.values.reduce(0, +) <= summary.clubCount
        else {
            throw ContractError.invalidField("categories")
        }
        return summary
    }

    private static func validate(_ response: DirectoryResponse) throws {
        guard response.schemaVersion == "1.0" else {
            throw ContractError.invalidField("schemaVersion")
        }
        for school in response.schools {
            guard school.slug.range(
                of: "^[a-z0-9]+(?:-[a-z0-9]+)*$",
                options: .regularExpression
            ) != nil else {
                throw ContractError.invalidField("slug")
            }
            guard school.verificationStatus == "verified",
                  school.clubCount.map({ $0 >= 0 }) ?? true,
                  school.categories.values.allSatisfy({ $0 >= 0 }),
                  school.clubCount.map({ school.categories.values.reduce(0, +) <= $0 }) ?? true,
                  school.location.country.count == 2,
                  !school.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !school.shortName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                throw ContractError.invalidField("school")
            }
            try validateHTTPS(school.canonicalURL)
        }
    }

    private static func validateHTTPS(_ url: URL) throws {
        guard url.scheme == "https", url.host() != nil, url.user() == nil, url.password() == nil else {
            throw ContractError.invalidField("canonicalUrl")
        }
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let fractionalFormatter = ISO8601DateFormatter()
            fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let standardFormatter = ISO8601DateFormatter()

            guard let date = fractionalFormatter.date(from: value)
                ?? standardFormatter.date(from: value)
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected an ISO 8601 timestamp"
                )
            }
            return date
        }
        return decoder
    }

    private static func jsonObject(from data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data)
        } catch {
            throw ContractError.invalidJSON
        }
    }

    private static func dictionary(_ value: Any?) throws -> [String: Any] {
        guard let dictionary = value as? [String: Any] else {
            throw ContractError.invalidJSON
        }
        return dictionary
    }

    private static func rejectUnknownKeys(
        in dictionary: [String: Any],
        allowing allowedKeys: Set<String>
    ) throws {
        let unknownKeys = Set(dictionary.keys).subtracting(allowedKeys).sorted()
        guard unknownKeys.isEmpty else {
            throw ContractError.unknownFields(unknownKeys)
        }
    }
}
