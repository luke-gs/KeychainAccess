//
//  SearchActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Specialised variance of launcher that only deals with `SearchActivity`.
open class SearchActivityLauncher: BaseActivityLauncher<SearchActivity> { }

extension SearchActivityLauncher {

    public static var `default`: SearchActivityLauncher = {
        guard let searchScheme = Bundle.main.infoDictionary?["DefaultSearchURLScheme"] as? String else {
            fatalError("`DefaultSearchURLScheme` is not declared in Info.plist")
        }
        return SearchActivityLauncher(scheme: searchScheme)
    }()

}
