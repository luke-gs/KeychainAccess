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

    case entityDetails(entity: Entity, delegate: SearchDelegate?)

    public enum EntityType {
        case person, vehicle, organisation, location
    }

}

public class EntityPresenter: Presenter {

    public init() {}

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        guard let presentable = presentable as? EntityScreen else { return UIViewController() }

        switch presentable {

        case .entityDetails(let entity, let delegate):
            let dataSources: [EntityDetailSectionsDataSource]

            switch entity {
            case is Person:
                dataSources = [
                    PersonMPOLDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
                    PersonFNCDetailsSectionsDataSource(baseEntity: entity, delegate: delegate)
                ]

                let viewModel = EntityDetailSectionsViewModel(initialSource: entity.source!,
                                                              dataSources: dataSources,
                                                              andMatchMaker: PersonMatchMaker())
                viewModel.recentlyViewed = UserSession.current.recentlyViewed

                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)
                entityDetailViewController.delegate = self
                return entityDetailViewController
            case is Vehicle:
                dataSources = [
                    VehicleMPOLDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
                    VehicleFNCDetailsSectionsDataSource(baseEntity: entity, delegate: delegate)
                ]

                let viewModel = EntityDetailSectionsViewModel(initialSource: entity.source!,
                                                              dataSources: dataSources,
                                                              andMatchMaker: VehicleMatchMaker())
                viewModel.recentlyViewed = UserSession.current.recentlyViewed

                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, VehicleSummaryDisplayable>(viewModel: viewModel)
                 entityDetailViewController.delegate = self
                return entityDetailViewController
            case is Address:
                dataSources = [LocationMPOLDetailsSectionsDataSource(baseEntity: entity, delegate: delegate)]
                let viewModel = EntityDetailSectionsViewModel(initialSource: MPOLSource.mpol,
                                                              dataSources: dataSources,
                                                              andMatchMaker: nil)
                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, AddressSummaryDisplayable>(viewModel: viewModel)
                entityDetailViewController.delegate = self
                return entityDetailViewController
            default:
                break
            }
            return UIViewController()
        case .help(let type):
            let content: HelpContent

            switch type {
            case .person:
                content = HelpContent(filename: "PersonSearchHelp", bundle: Bundle.main)
            case .vehicle:
                content = HelpContent(filename: "VehicleSearchHelp", bundle: Bundle.main)
            case .location:
                content = HelpContent(filename: "LocationSearchHelp", bundle: Bundle.main)
            case .organisation:
                content = HelpContent(filename: "OrganisationSearchHelp", bundle: Bundle.main)
            }
            
            return HelpViewController(content: content)

        case .createEntity(let type):
            let title: String

            switch type {
            case .person:
                let personViewController = PersonEditViewController()
                personViewController.title = "New Person"
                return UINavigationController(rootViewController: personViewController)
            case .vehicle:
                let vehicleViewController = VehicleEditViewController()
                vehicleViewController.title = "New Vehicle"
                return UINavigationController(rootViewController: vehicleViewController)
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
        guard let presentable = presentable as? EntityScreen else { return }

        switch presentable {
        case .createEntity:
            from.present(to, animated: true, completion: nil)
        default:
            from.show(to, sender: from)
        }
    }


    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is EntityScreen.Type
    }

}

extension EntityPresenter: EntityDetailSplitViewControllerDelegate {

    public func entityDetailSplitViewController<Details, Summary>(_ entityDetailSplitViewController: EntityDetailSplitViewController<Details, Summary>, didPresentEntity entity: MPOLKitEntity) {
    }

    public func entityDetailSplitViewController<Details, Summary>(_ entityDetailSplitViewController: EntityDetailSplitViewController<Details, Summary>, didActionOnEntity entity: MPOLKitEntity) {

        // Temporary implementation of this action. Change to suit
        let recentlyActioned = UserSession.current.recentlyActioned
        if recentlyActioned.contains(entity) {
            recentlyActioned.remove(entity)
        } else {
            recentlyActioned.add(entity)
        }
    }

}
