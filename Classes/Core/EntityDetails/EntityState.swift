//
//  EntityState.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public enum EntityResultState: Equatable {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

public enum EntityDetailState: Equatable {
    case empty
    case loading
    case result([EntityResultState])
    case error(Error)
}

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
