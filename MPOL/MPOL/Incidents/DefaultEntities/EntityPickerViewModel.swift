//
//  EntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

protocol EntityPickerDelegate: class {
    func finishedPicking(_ entity: MPOLKitEntity)
}

public class EntityPickerViewModel {

    open var entities = [MPOLKitEntity]()
    weak var delegate: EntityPickerDelegate?

    var currentLoadingManagerState: LoadingStateManager.State {
        return entities.isEmpty ? .noContent : .loaded
    }

    init() {
        for entity in UserSession.current.recentlyViewed.entities {
            entities.append(entity)
        }
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {

        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("No Displayable for Entity Type")
        }
    }
}
