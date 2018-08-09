//
//  EntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol EntityPickerDelegate: class {
    func finishedPicking(_ entity: MPOLKitEntity)
}

public protocol EntityPickerViewModel {

    var entities: [MPOLKitEntity]{ get }

    var delegate: EntityPickerDelegate? { get set }

    var currentLoadingManagerState: LoadingStateManager.State { get }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable
}

public extension EntityPickerViewModel {

    var currentLoadingManagerState: LoadingStateManager.State {
        return entities.isEmpty ? .noContent : .loaded
    }
}
