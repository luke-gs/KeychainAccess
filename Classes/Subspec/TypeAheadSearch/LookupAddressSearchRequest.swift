//
//  LookupAddressSearchRequest.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class LookupAddressSearchRequest: EntitySearchRequest<LookupAddress> {

    public let searchText: String
    public let maxResults: Int

    public init(searchText: String, maxResults: Int = 20) {
        self.searchText = searchText
        self.maxResults = maxResults
        super.init(parameters: ["searchString" : searchText, "maxResults" : maxResults])
    }

    override public init(parameters: [String : Any]) {
        fatalError("use `init(searchText:maxResults:)` instead.")
    }
}
