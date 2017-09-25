//
//  MatchMaker.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public protocol FetchMatch {
    var initialSource: EntitySource { get }
    var resultSource: EntitySource { get }
    func match(_ entity: MPOLKitEntity) -> Fetchable
}

open class MatchMaker {

    public init() { }

    open var matches: [FetchMatch]? {
        return []
    }

    public func findMatch(for entity: MPOLKitEntity, with initialSource: EntitySource, and destinationSource: EntitySource) -> Fetchable? {
        let fetchable = matches?.filter {
            $0.initialSource.serverSourceName == initialSource.serverSourceName
                && destinationSource.serverSourceName == destinationSource.serverSourceName}.first?.match(entity)
        return fetchable
    }
}
