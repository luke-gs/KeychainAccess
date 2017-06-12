//
//  SearchResult.swift
//  MPOLKit
//
//  Created by Herli Halim on 13/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

public struct SearchResult<T>: Unboxable {

    public let range: CountableRange<Int>
    public let results: [T]
    
    public init(unboxer: Unboxer) throws {
        
        let start: Int = try unboxer.unbox(key: CodingKeys.start.rawValue)
        let end: Int = try unboxer.unbox(key: CodingKeys.end.rawValue)
        
        range = start..<end
        results = try unboxer.unbox(key: CodingKeys.results.rawValue)
        
    }
    
    private enum CodingKeys: String {
        case start = "itemStart"
        case end = "itemEnd"
        case count = "searchResultsCount"
        case results = "searchResults"
    }
    
}
