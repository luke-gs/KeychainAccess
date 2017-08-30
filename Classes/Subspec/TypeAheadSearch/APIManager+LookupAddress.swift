//
//  APIManager+LookupAddress.swift
//  MPOLKit
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit
import Alamofire

extension APIManager {

    /// Search for lookup address using the search request. This is intended for
    /// to retrieve valid addresses suggestion.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of the lookup addresses suggestion.
    ///   - searchText: The search text to retrieve suggestion.
    /// - Returns: A promise to return array of LookupAddress.
    open func typeAheadSearchAddress<T: EntitySearchRequestable>(in source: EntitySource, with request: T) -> Promise<[T.ResultClass]> {

        let path = "{source}/entity/location/search/typeahead"
        var parameters = request.parameters
        parameters["source"] = source

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)

        return try! performRequest(networkRequest)

    }

}
