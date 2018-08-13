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
            switch entity {
            case is Person:
                //                viewModel.shouldAutomaticallyFetchFromSubsequentDatasources = true
                //                viewModel.recentlyViewed = UserSession.current.recentlyViewed

                //                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)
                //
                //
                //                entityDetailViewController.delegate = self

                let ds1 = PersonPSCoreDetailsSectionsDataSource(delegate: delegate)
                let ds2 = PersonNATDetailsSectionsDataSource(delegate: delegate)
                let ds3 = PersonRDADetailsSectionsDataSource(delegate: delegate)

                let strat1 = PersonRetrieveStrategy(source: MPOLSource.pscore)
                let strat2 = PersonRetrieveStrategy(source: MPOLSource.nat)
                let strat3 = PersonRetrieveStrategy(source: MPOLSource.rda)

                let vm1 = FancyEntityDetailsDatasourceViewModel(datasource: ds1, strategy: strat1)
                let vm2 = FancyEntityDetailsDatasourceViewModel(datasource: ds2, strategy: strat2)
                let vm3 = FancyEntityDetailsDatasourceViewModel(datasource: ds3, strategy: strat3)

                let viewModel = FancyEntityDetailsViewModel(datasourceViewModels: [vm1, vm2, vm3],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = FancyEntityDetailsSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel, pickerViewModel: DefaultEntityPickerViewModel())

                return entityDetailViewController
            case is Vehicle:

                //                viewModel.recentlyViewed = UserSession.current.recentlyViewed
                //                viewModel.shouldAutomaticallyFetchFromSubsequentDatasources = true
                //
                //                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, VehicleSummaryDisplayable>(viewModel: viewModel)
                //                 entityDetailViewController.delegate = self

                let ds1 = VehiclePSCoreDetailsSectionsDataSource(delegate: delegate)
                let ds2 = VehicleNATDetailsSectionsDataSource(delegate: delegate)
                let ds3 = VehicleRDADetailsSectionsDataSource(delegate: delegate)

                let strat1 = VehicleRetrieveStrategy(source: MPOLSource.pscore)
                let strat2 = VehicleRetrieveStrategy(source: MPOLSource.nat)
                let strat3 = VehicleRetrieveStrategy(source: MPOLSource.rda)

                let vm1 = FancyEntityDetailsDatasourceViewModel(datasource: ds1, strategy: strat1)
                let vm2 = FancyEntityDetailsDatasourceViewModel(datasource: ds2, strategy: strat2)
                let vm3 = FancyEntityDetailsDatasourceViewModel(datasource: ds3, strategy: strat3)

                let viewModel = FancyEntityDetailsViewModel(datasourceViewModels: [vm1, vm2, vm3],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = FancyEntityDetailsSplitViewController<EntityDetailsDisplayable, VehicleSummaryDisplayable>(viewModel: viewModel, pickerViewModel: DefaultEntityPickerViewModel())

                return entityDetailViewController
            case is Address:

//                viewModel.recentlyViewed = UserSession.current.recentlyViewed
//                let entityDetailViewController = EntityDetailSplitViewController<EntityDetailsDisplayable, AddressSummaryDisplayable>(viewModel: viewModel)
//                entityDetailViewController.delegate = self

                let ds1 = LocationMPOLDetailsSectionsDataSource(delegate: delegate)
                let strat1 = LocationRetrieveStrategy(source: MPOLSource.pscore)
                let vm1 = FancyEntityDetailsDatasourceViewModel(datasource: ds1, strategy: strat1)

                let viewModel = FancyEntityDetailsViewModel(datasourceViewModels: [vm1],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = FancyEntityDetailsSplitViewController<EntityDetailsDisplayable, AddressSummaryDisplayable>(viewModel: viewModel, pickerViewModel: DefaultEntityPickerViewModel())
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
