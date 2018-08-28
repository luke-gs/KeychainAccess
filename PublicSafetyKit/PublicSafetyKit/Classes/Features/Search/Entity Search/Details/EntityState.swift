//
//  EntityState.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit

/// The entity retrieval strategy
public protocol EntityRetrievalStrategy {

    /// Fetch the entity details
    ///
    /// - Parameter entity: The entity to use as a reference for the fetch
    /// - Returns: A promise of an array of results
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>?
}

/// The entity result state
///
/// - summary: A partial summary of the entity
/// - detail: A full detail of the entity
public enum EntityResultState: Equatable {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

/// The entity details fetch state
///
/// - empty: No fetch has been performed
/// - fetching: Currently fetching
/// - result: A fetch yielded a result
/// - error: An error occured
public enum EntityDetailState: Equatable {
    case empty
    case fetching
    case result([EntityResultState])
    case error(Error)
}

//MARK:- Equality

public func == (lhs: EntityDetailState, rhs: EntityDetailState) -> Bool {
    switch (lhs, rhs) {
    case (.result(let lhsStates), .result(let rhsStates)):
        return lhsStates == rhsStates
    default:
        return true
    }
}

public func == (lhs: EntityResultState, rhs: EntityResultState) -> Bool {
    switch (lhs, rhs) {
    case (.summary(let lhsEntity), .detail(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.detail(let lhsEntity), .summary(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.detail(let lhsEntity), .detail(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.summary(let lhsEntity), .summary(let rhsEntity)):
        return lhsEntity == rhsEntity
    }
}
