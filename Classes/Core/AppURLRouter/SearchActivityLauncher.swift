//
//  SearchActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum SearchActivity: CustomStringConvertible {

    case searchEntity(term: Searchable, source: EntitySource)
    case viewDetails(id: String, entityType: String, source: EntitySource)

    public var description: String {
        switch self {
        case .searchEntity(_, _):
            return "search"
        case .viewDetails(_, _, _):
            return "viewDetails"
        }
    }
}

open class SearchActivityLauncher {

    public let scheme: String

    public init(scheme: String) {
        self.scheme = scheme
    }

    convenience public init?() {
        guard let searchScheme = Bundle.main.infoDictionary?[""] as? String else {
            return nil
        }
        self.init(scheme: searchScheme)
    }

    open func launch(_ activity: SearchActivity) throws {

        var components = URLComponents()
        components.scheme = scheme
        components.path = "/" + String(describing: activity)

        guard let url = components.url else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
