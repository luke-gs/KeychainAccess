//
//  MPOLSearchViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 19/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

class MPOLSearchViewModel: SearchViewModel {
    var recentViewModel: SearchRecentsViewModel = MPOLSearchRecentsViewModel()
    var dataSources: [SearchDataSource] = [PersonSearchDataSource(), VehicleSearchDataSource()]
    
    func detailViewController(for entity: MPOLKitEntity) -> UIViewController? {
        let viewController = EntityDetailsSplitViewController(entity: entity as! Entity)
        
        // FIXME: - Sample code to handle different entity
        if entity is Person {
            viewController.view.backgroundColor = .red
        } else if entity is Vehicle {
            viewController.view.backgroundColor = .yellow
        }
        
        return viewController
    }
}

class MPOLSearchRecentsViewModel: SearchRecentsViewModel {

    var title: String = "MPOL"

    var recentlyViewed: [MPOLKitEntity] = []
    
    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) {
        let entity = recentlyViewed[indexPath.item]
        
        cell.style = .detail
        cell.decorate(with: entity as! EntitySummaryDisplayable)
    }

    func summaryIcon(for searchable: Searchable) -> UIImage? {
        guard let type = searchable.type else { return nil }

        // Could probably enum this out as well
        switch type {
        case "Person":
            return AssetManager.shared.image(forKey: .entityPerson)
        case "Vehicle":
            return AssetManager.shared.image(forKey: .entityCar)
        default:
            return AssetManager.shared.image(forKey: .entityPerson)
        }
    }
}
