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

    /// Search for lookup address using the search text. This is intended for
    /// to retrieve valid addresses suggestion.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of the lookup addresses suggestion.
    ///   - searchText: The search text to retrieve suggestion.
    /// - Returns: A promise to return array of LookupAddress.
    open func typeAheadSearchAddress(in source: EntitySource, with searchText: String) -> Promise<[LookupAddress]> {

        let path = "{source}/entity/location/typeaheadsearch"

        let parameters = ["source" : source, "searchString" : searchText] as [String : Any]

        let result = try! urlQueryBuilder.urlPathWith(template: path, parameters: parameters)

        let requestPath = url(with: result.path)
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: result.parameters)

        return dataRequestPromise(encodedURLRequest)
    }

}
