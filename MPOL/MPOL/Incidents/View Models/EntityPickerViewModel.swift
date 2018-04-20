//
//  EntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class EntityPickerViewModel {

    
    public var entities = [MPOLKitEntity]()
    public let dismissClosure: (MPOLKitEntity) -> ()

    init(dismissClosure: @escaping (MPOLKitEntity) -> ()) {

        self.dismissClosure = dismissClosure
        
        //inti displayables
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
            fatalError("Entity is Not a valid Type")
        }
    }

    func currentLoadingManagerState() -> LoadingStateManager.State {
        return entities.isEmpty ? .noContent : .loaded
    }

}
