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
                // FIXME: Refactor all of these data sources set up.
//                dataSources = [
//                    PersonPSCoreDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
//                    PersonNATDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
//                    PersonRDADetailsSectionsDataSource(baseEntity: entity, delegate: delegate)
//                ]
//
//                let viewModel = EntityDetailSectionsViewModel(initialSource: entity.source!,
//                                                              dataSources: dataSources,
//                                                              andMatchMaker: PersonMatchMaker())
//                viewModel.shouldAutomaticallyFetchFromSubsequentDatasources = true
//                viewModel.recentlyViewed = UserSession.current.recentlyViewed

//                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)
//
//
//                entityDetailViewController.delegate = self

                let ds1 = TestFancyEntityDetailsDataSource(source: MPOLSource.pscore)
                let ds2 = TestFancyEntityDetailsDataSource(source: MPOLSource.nat)
                let ds3 = TestFancyEntityDetailsDataSource(source: MPOLSource.rda)

                let vm1 = FancyEntityDetailsDatasourceViewModel(datasource: ds1,
                                                                strategy: PersonRetrieveStrategy(source: MPOLSource.pscore))
                let vm2 = FancyEntityDetailsDatasourceViewModel(datasource: ds2,
                                                                strategy: PersonRetrieveStrategy(source: MPOLSource.nat))
                let vm3 = FancyEntityDetailsDatasourceViewModel(datasource: ds3,
                                                                strategy: PersonRetrieveStrategy(source: MPOLSource.rda))

                let viewModels: [FancyEntityDetailsDatasourceViewModel] = [vm1, vm2, vm3]

                let viewModel = FancyEntityDetailsViewModel(datasourceViewModels: viewModels,
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = FancyEntityDetailsSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)

                return entityDetailViewController
            case is Vehicle:
                dataSources = [
                    VehiclePSCoreDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
                    VehicleNATDetailsSectionsDataSource(baseEntity: entity, delegate: delegate),
                    VehicleRDADetailsSectionsDataSource(baseEntity: entity, delegate: delegate)
                ]

                let viewModel = EntityDetailSectionsViewModel(initialSource: entity.source!,
                                                              dataSources: dataSources,
                                                              andMatchMaker: VehicleMatchMaker())
                viewModel.recentlyViewed = UserSession.current.recentlyViewed
                viewModel.shouldAutomaticallyFetchFromSubsequentDatasources = true

                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, VehicleSummaryDisplayable>(viewModel: viewModel)
                 entityDetailViewController.delegate = self
                return entityDetailViewController
            case is Address:
                dataSources = [LocationMPOLDetailsSectionsDataSource(baseEntity: entity, delegate: delegate)]
                let viewModel = EntityDetailSectionsViewModel(initialSource: MPOLSource.pscore,
                                                              dataSources: dataSources,
                                                              andMatchMaker: nil)
                viewModel.recentlyViewed = UserSession.current.recentlyViewed
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
}
