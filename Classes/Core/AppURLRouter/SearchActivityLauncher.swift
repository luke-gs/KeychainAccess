//
//  SearchActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

import Alamofire

public protocol ActivityLauncherType {

    associatedtype Activity: ActivityType

    func launch(_ activity: Activity, using navigator: AppURLNavigator) throws

}

public protocol ActivityType: Parameterisable {
    var name: String { get }
}

public enum SearchActivity: ActivityType {

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
}

open class SearchActivityLauncher: ActivityLauncherType {

    public typealias Activity = SearchActivity

    public let scheme: String

    public init(scheme: String) {
        self.scheme = scheme
    }

    open func launch(_ activity: SearchActivity, using navigator: AppURLNavigator) throws {
        try? navigator.open(scheme, host: nil, path: activity.name, parameters: activity.parameters, completionHandler: nil)
    }
}

open class SearchActivityHandler {

    public var supportedActivities: [(scheme: String, host: String?, path: String)]? = nil
    public let scheme: String

    public var onS: ((Searchable, String) -> Void)? = nil
    public var onV: ((String, String, String) -> Void)? = nil

    public init(scheme: String) {
        self.scheme = scheme
        supportedActivities = [
            (scheme: scheme, host: nil, path: "search"),
            (scheme: scheme, host: nil, path: "viewDetails")
        ]
    }

    open func handle(_ urlString: String, values: [String: Any]?) -> Bool {
        guard let components = URLComponents(string: urlString) else {
            return false
        }

        var path = components.path
        // Assume it starts with `/` and strips it
        if path.count > 1 {
            let lowerBound = path.index(path.startIndex, offsetBy: 1)
            path = String(path[lowerBound...])
        }

        if path == "search" {

            onS?(Searchable(text: values?["term"] as? String ?? "S"), values?["source"] as? String ?? "mpol")

        } else {
            onV?(values?["id"] as? String ?? "123", values?["entityType"] as? String ?? "person", values?["source"] as? String ?? "mpol")
        }

        /*
         "id": id,
         "entityType": entityType,
         "source": source
 */

        print(path)
        print(values)

        let controller = UIAlertController(title: path, message: values?.description, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))



        return true
    }

}

extension SearchActivityLauncher {

    public static var `default`: SearchActivityLauncher = {
        guard let searchScheme = Bundle.main.infoDictionary?["DefaultSearchURLScheme"] as? String else {
            fatalError("`DefaultSearchURLScheme` is not declared in Info.plist")
        }
        return SearchActivityLauncher(scheme: searchScheme)
    }()

}
