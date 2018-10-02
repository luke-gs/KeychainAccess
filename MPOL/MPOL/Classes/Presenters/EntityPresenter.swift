//
//  EntityPresenter.swift
//  MPOL
//
//  Created by KGWH78 on 11/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

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
                let ds1 = PersonPSCoreDetailsSectionsDataSource(delegate: delegate)
                let ds2 = PersonNATDetailsSectionsDataSource(delegate: delegate)
                let ds3 = PersonRDADetailsSectionsDataSource(delegate: delegate)

                let strat1 = PersonRetrieveStrategy(source: MPOLSource.pscore)
                let strat2 = PersonRetrieveStrategy(source: MPOLSource.nat)
                let strat3 = PersonRetrieveStrategy(source: MPOLSource.rda)

                let vm1 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds1, strategy: strat1, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm2 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds2, strategy: strat2, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm3 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds3, strategy: strat3, entityPickerViewModel: DefaultEntityPickerViewModel())

                let viewModel = EntityDetailsViewModel(dataSourceViewModels: [vm1, vm2, vm3],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = EntityDetailsSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)

                return entityDetailViewController
            case is Vehicle:

                let ds1 = VehiclePSCoreDetailsSectionsDataSource(delegate: delegate)
                let ds2 = VehicleNATDetailsSectionsDataSource(delegate: delegate)
                let ds3 = VehicleRDADetailsSectionsDataSource(delegate: delegate)

                let strat1 = VehicleRetrieveStrategy(source: MPOLSource.pscore)
                let strat2 = VehicleRetrieveStrategy(source: MPOLSource.nat)
                let strat3 = VehicleRetrieveStrategy(source: MPOLSource.rda)

                let vm1 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds1, strategy: strat1, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm2 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds2, strategy: strat2, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm3 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds3, strategy: strat3, entityPickerViewModel: DefaultEntityPickerViewModel())

                let viewModel = EntityDetailsViewModel(dataSourceViewModels: [vm1, vm2, vm3],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = EntityDetailsSplitViewController<EntityDetailsDisplayable, VehicleSummaryDisplayable>(viewModel: viewModel)

                return entityDetailViewController
            case is Organisation:
                let ds1 = OrganisationPSCoreDetailsSectionsDataSource(delegate: delegate)
                let ds2 = OrganisationNATDetailsSectionsDataSource(delegate: delegate)
                let ds3 = OrganisationRDADetailsSectionsDataSource(delegate: delegate)
                
                let strat1 = OrganisationRetrieveStrategy(source: MPOLSource.pscore)
                let strat2 = OrganisationRetrieveStrategy(source: MPOLSource.nat)
                let strat3 = OrganisationRetrieveStrategy(source: MPOLSource.rda)
                
                let vm1 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds1, strategy: strat1, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm2 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds2, strategy: strat2, entityPickerViewModel: DefaultEntityPickerViewModel())
                let vm3 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds3, strategy: strat3, entityPickerViewModel: DefaultEntityPickerViewModel())
                
                let viewModel = EntityDetailsViewModel(dataSourceViewModels: [vm1, vm2, vm3],
                                                       initialSource: entity.source!,
                                                       referenceEntity: entity)
                
                let entityDetailViewController = EntityDetailsSplitViewController<EntityDetailsDisplayable, OrganisationSummaryDisplayable>(viewModel: viewModel)
                
                return entityDetailViewController
                
            case is Address:

                let ds1 = LocationMPOLDetailsSectionsDataSource(delegate: delegate)
                let strat1 = LocationRetrieveStrategy(source: MPOLSource.pscore)

                let vm1 = EntityDetailsDataSourceViewModel<EntityDetailsDisplayable>(dataSource: ds1, strategy: strat1)

                let viewModel = EntityDetailsViewModel(dataSourceViewModels: [vm1],
                                                            initialSource: entity.source!,
                                                            referenceEntity: entity)

                let entityDetailViewController = EntityDetailsSplitViewController<EntityDetailsDisplayable, AddressSummaryDisplayable>(viewModel: viewModel)
                
                return entityDetailViewController
            default:
                break
            }
            return UIViewController()
        case .help(let type):
            let htmlVC: HTMLTextViewController
            // styles
            let lightURL = Bundle.main.url(forResource: "LightModeStyle", withExtension: "css")!
            let darkURL = Bundle.main.url(forResource: "DarkModeStyle", withExtension: "css")!
            let styleMap: [UserInterfaceStyle: URL] = [.light: lightURL, .dark: darkURL]
            
            switch type {
            case .person:
                let url = Bundle.main.url(forResource: "PersonSearchHelp", withExtension: "html")!
                htmlVC = try! HTMLTextViewController.init(title: NSLocalizedString("Person Search", comment: ""),
                                                          htmlURL: url, styleMap: styleMap, actions: nil)
            case .vehicle:
                let url = Bundle.main.url(forResource: "VehicleSearchHelp", withExtension: "html")!
                htmlVC = try! HTMLTextViewController.init(title: NSLocalizedString("Vehicle Search", comment: ""),
                                                          htmlURL: url, styleMap: styleMap, actions: nil)
            case .location:
                let url = Bundle.main.url(forResource: "LocationSearchHelp", withExtension: "html")!
                htmlVC = try! HTMLTextViewController.init(title: NSLocalizedString("Location Search", comment: ""),
                                                          htmlURL: url, styleMap: styleMap, actions: nil)
            case .organisation:
                let url = Bundle.main.url(forResource: "OrganisationSearchHelp", withExtension: "html")!
                htmlVC = try! HTMLTextViewController.init(title: NSLocalizedString("Organisation Search", comment: ""),
                                                          htmlURL: url, styleMap: styleMap, actions: nil)
            }
            
            htmlVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                                         style: .plain,
                                                                         target: htmlVC,
                                                                         action: #selector(UIViewController.dismissAnimated))
            
            
            let navVC = ModalNavigationController(rootViewController: htmlVC)
            navVC.modalPresentationStyle = .pageSheet
            
            return navVC

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
        case .entityDetails:
            if from is EntityDetailFormViewController {
                from.splitViewController?.navigationController?.show(to, sender: from)
            } else {
                from.show(to, sender: from)
            }
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is EntityScreen.Type
    }
}
