//
//  EntityPresenter.swift
//  MPOL
//
//  Created by KGWH78 on 11/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit


public enum EntityScreen: Presentable {

    case help(type: EntityType)

    case createEntity(type: EntityType)

    case entityDetails(entity: Entity)

    public enum EntityType {
        case person, vehicle, organisation, location
    }

}


public class EntityPresenter: Presenter {

    public init() {}

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        guard let presentable = presentable as? EntityScreen else { return UIViewController() }

        switch presentable {

        case .entityDetails(let entity):
            let dataSource: EntityDetailSectionsDataSource

            if entity is Person {
                dataSource = PersonDetailsSectionsDataSource(baseEntity: entity)
            } else {
                dataSource = VehicleDetailsSectionsDataSource(baseEntity: entity)
            }

            return EntityDetailSplitViewController(dataSource: dataSource)

        case .help(let type):
            let details: SearchHelpDetails

            switch type {
            case .person:
                details = SearchHelpDetails(filename: "PersonSearchHelp", bundle: Bundle.main)
            case .vehicle:
                details = SearchHelpDetails(filename: "VehicleSearchHelp", bundle: Bundle.main)
            case .location:
                details = SearchHelpDetails(filename: "LocationSearchHelp", bundle: Bundle.main)
            case .organisation:
                details = SearchHelpDetails(filename: "OrganisationSearchHelp", bundle: Bundle.main)
            }
            
            return SearchHelpViewController(details: details)

        case .createEntity(let type):
            let title: String

            switch type {
            case .person:
                title = NSLocalizedString("New Person", comment: "")
            case .vehicle:
                title = NSLocalizedString("New Vehicle", comment: "")
            case .location:
                title = NSLocalizedString("New Location", comment: "")
            case .organisation:
                title = NSLocalizedString("New Organisation", comment: "")
            }

            let viewController = UIViewController()
            viewController.title = title
            viewController.view.backgroundColor = .white
            return viewController
            
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        from.show(to, sender: from)
    }


    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is EntityScreen.Type
    }

}
