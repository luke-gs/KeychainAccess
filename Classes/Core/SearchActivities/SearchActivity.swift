//
//  SearchActivity.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum SearchActivity: ActivityType, Codable {

    case launchApp
    case searchEntity(term: Searchable, source: String)
    case viewDetails(id: String, entityType: String, source: String)

    public var name: String {
        switch self {
        case .launchApp:
            return "launchApp"
        case .searchEntity(_, _):
            return "search"
        case .viewDetails(_, _, _):
            return "viewDetails"
        }
    }

    public var parameters: [String : Any] {

        // Known parameters, so this should not fail!
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)

        let parameters = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return parameters
    }

    // Codable is hard...

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SearchActivityType.self, forKey: .activityType)

        switch type {
        case .launchApp:
            self = .launchApp
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
        case .launchApp:
            try container.encode(SearchActivityType.launchApp, forKey: .activityType)
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
        case launchApp
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
    }

    private struct ViewEntityDetailsParameters: Codable {
        let id: String
        let entityType: String
        let source: String
    }
}
