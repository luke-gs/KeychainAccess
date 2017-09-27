//
//  MatchMaker.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// Defines the rules of how two datasources should be matched together
public protocol DataMatchable {

    /// The initial data source
    var initialSource: EntitySource { get }

    /// The data source to be matched
    var resultSource: EntitySource { get }

    /// Define custom rules for matching the specific data sources
    /// to be used to fetch the entity details from the result source
    ///
    /// - Parameter entity: the base entity to match
    /// - Returns: a fetchable object adhering to specific rules and hitting the correct endpoint to get entity results/details
    func match(_ entity: MPOLKitEntity) -> Fetchable
}

/// A convenience object that is used to store and attempt to find a match of datasources
open class MatchMaker {


    /// Public init
    public init() { }

    /// An array of `FetchMatch`es to be implemented in the subclass
    open var matches: [DataMatchable]? {
        MPLUnimplemented()
    }


    /// Attempts to find a match from all the `FetchMatch`es given intial and destination data sources
    ///
    /// Override this function if you need custom behaviour for finding the correct match
    ///
    /// - Parameters:
    ///   - entity: the entity to match for
    ///   - initialSource: the initial data source of the entity
    ///   - destinationSource: the resultant data source to match for
    /// - Returns: a fetchable object adhering to specific rules and hitting the correct endpoint to get entity results/details
    public func findMatch(for entity: MPOLKitEntity,
                          withInitialSource initialSource: EntitySource,
                          andDestinationSource destinationSource: EntitySource) -> Fetchable?
    {
        let fetchable = matches?.filter {
            $0.initialSource.serverSourceName == initialSource.serverSourceName
                && destinationSource.serverSourceName == destinationSource.serverSourceName}.first?.match(entity)
        return fetchable
    }
}
