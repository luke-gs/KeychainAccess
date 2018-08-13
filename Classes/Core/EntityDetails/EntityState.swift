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
    /// - Parameter entity: the entity to use as a reference for the fetch
    /// - Returns: a promise of an array of results
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>?
}

/// The entity result state
///
/// - summary: a partial summary of the entity
/// - detail: a full detail of the entity
public enum EntityResultState: Equatable {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

/// The entity details fetch state
///
/// - empty: no fetch has been performed
/// - fetching: currently fetching
/// - result: a fetch yielded a result
/// - error: an error occured
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
