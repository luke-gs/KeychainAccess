//
//  SearchActivity.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum SearchActivity: ActivityType, Codable {

    case searchEntity(term: Searchable, source: String)
    case viewDetails(id: String, entityType: String, source: String)

    public var name: String {
        switch self {
        case .searchEntity(_, _):
            return "search"
        case .viewDetails(_, _, _):
            return "viewDetails"
        }
    }

    public var parameters: [String : Any] {
        switch self {
        case .searchEntity(let term, let source):
            return [
                "term": term.text,
                "source": source
            ]
        case .viewDetails(let id, let entityType, let source):
            return [
                "id": id,
                "entityType": entityType,
                "source": source
            ]
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SearchActivityType.self, forKey: .activityType)

        switch type {
        case .searchEntity:
            let parameters = try container.decode(SearchEntityParameters.self, forKey: .searchEntityParameters)
            self = .searchEntity(term: parameters.term, source: parameters.source)
        case .viewDetails:
            let parameters = try container.decode(ViewEntityDetailsParameters.self, forKey: .viewEntityDetailsParameters)
            self = .viewDetails(id: parameters.id, entityType: parameters.entityType, source: parameters.source)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .searchEntity(let term, let source):
            try container.encode(SearchActivityType.searchEntity, forKey: .activityType)
            try container.encode(SearchEntityParameters(term: term, source: source), forKey: .searchEntityParameters)
        case .viewDetails(let id, let entityType, let source):
            try container.encode(SearchActivityType.viewDetails, forKey: .activityType)
            try container.encode(ViewEntityDetailsParameters(id: id, entityType: entityType, source: source), forKey: .viewEntityDetailsParameters)
        }
    }

    // MARK: - Internal Representations
    // Required for Codable

    private enum SearchActivityType: String, Codable {
        case searchEntity
        case viewDetails
    }

    private enum CodingKeys: String, CodingKey {
        case activityType
        case searchEntityParameters
        case viewEntityDetailsParameters
    }

    private struct SearchEntityParameters: Codable {
        let term: Searchable
        let source: String

        init(term: Searchable, source: String) {
            self.term = term
            self.source = source
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let data = NSKeyedArchiver.MPL_securelyArchivedData(withRootObject: term).base64EncodedString()
            try container.encode(data, forKey: .term)
            try container.encode(source, forKey: .source)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let data = try container.decode(Data.self, forKey: .term).base64EncodedData()
            let searchable: Searchable? = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(with: data)

            term = searchable!
            source = try container.decode(String.self, forKey: .source)
        }

        private enum CodingKeys: String, CodingKey {
            case term
            case source
        }
    }

    private struct ViewEntityDetailsParameters: Codable {
        let id: String
        let entityType: String
        let source: String
    }
}
