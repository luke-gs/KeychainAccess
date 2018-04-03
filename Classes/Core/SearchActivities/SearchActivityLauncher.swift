//
//  SearchActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

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

extension SearchActivityLauncher {

    public static var `default`: SearchActivityLauncher = {
        guard let searchScheme = Bundle.main.infoDictionary?["DefaultSearchURLScheme"] as? String else {
            fatalError("`DefaultSearchURLScheme` is not declared in Info.plist")
        }
        return SearchActivityLauncher(scheme: searchScheme)
    }()

}
