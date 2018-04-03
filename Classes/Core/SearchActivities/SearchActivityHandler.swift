//
//  SearchActivityHandler.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol SearchActivityHandlerDelegate {
    func searchActivityHandler(_ handler: SearchActivityHandler, launchedSearchActivity: SearchActivity)
}

public class SearchActivityHandler: ActivityHandler {

    public var delegate: SearchActivityHandlerDelegate?

    public init(scheme: String) {
        let supportedActivities: [(scheme: String, host: String?, path: String)] = [
            (scheme: scheme, host: nil, path: "launchApp"),
            (scheme: scheme, host: nil, path: "search"),
            (scheme: scheme, host: nil, path: "viewDetails")
        ]
        super.init(scheme: scheme, supportedActivities: supportedActivities)
    }

    override public func handle(_ urlString: String, values: [String: Any]?) -> Bool {

        let decoder = JSONDecoder()
        guard let values = values,
            let data = try? JSONSerialization.data(withJSONObject: values, options: []),
            let searchActivity = try? decoder.decode(SearchActivity.self, from: data) else {
                return false
        }

        delegate?.searchActivityHandler(self, launchedSearchActivity: searchActivity)

        return true
    }

}
