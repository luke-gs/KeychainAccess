//
//  LandingPresenter.swift
//  ClientKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class LandingPresenter: AppGroupLandingPresenter {

    override public var termsAndConditionsVersion: String {
        return TermsAndConditionsVersion
    }

    override public var whatsNewVersion: String {
        return WhatsNewVersion
    }

    override public var appWindow: UIWindow {
        return (UIApplication.shared.delegate as? AppDelegate)!.window!
    }

    override public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LandingScreen

        switch presentable {

        case .login:
            let loginViewController = LoginViewController(mode: .usernamePassword(delegate: self))

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                                             subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

            #if DEBUG
                loginViewController.usernameField.textField.text = "matt"
                loginViewController.passwordField.textField.text = "vicroads"
            #endif

            return loginViewController

        case .termsAndConditions:
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
            tsAndCsVC.delegate = self
            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .formSheet

            return navController

        case .whatsNew:
            let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New", detail: "Swipe through and discover the new features and updates that have been included in this release. Refer to the release summary for full update notes.")
            let whatsNewSecondPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "RefreshMagnify"), title: "Search", detail: "Search for persons. Search for vehicles.")
            let whatsNewThirdPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "Avatar 1"), title: "Details", detail: "View details for person and vehicle entities.")

            let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage, whatsNewSecondPage, whatsNewThirdPage])
            whatsNewVC.delegate = self

            return whatsNewVC

        case .landing:
            func settingsBarButtonItem() -> UIBarButtonItem {
                let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
                settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
                return settingsItem
            }

            
            let strategy = LookupAddressLocationSearchStrategy<Address>(source: MPOLSource.gnaf, helpPresentable: EntityScreen.help(type: .location))
            let locationDataSource = LocationSearchDataSource(strategy: strategy, advanceOptions: LookupAddressLocationAdvancedOptions())

            strategy.onResultModelForCoordinate = { coordinate in
                let radius = strategy.radiusConfiguration.radiusOptions.first ?? 100.0
                let searchType = LocationMapSearchType.radius(coordinate: coordinate, radius: radius)
                let parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
                let request = LocationMapSearchRequest(source: .gnaf, request: parameters)
                let aggregatedSearch = AggregatedSearch<Address>(requests: [request])
                let viewModel = MapSummarySearchResultViewModel(searchStrategy: strategy, title: "Current Location", aggregatedSearch: aggregatedSearch)
                viewModel.searchType = searchType
                return viewModel
            }

            strategy.onResultModelForResult = { (lookupResult, searchable) in
                let coordinate = lookupResult.location.coordinate
                let radius = strategy.radiusConfiguration.radiusOptions.first ?? 100.0
                let searchType = LocationMapSearchType.radius(coordinate: coordinate, radius: radius)
                let parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
                let request = LocationMapSearchRequest(source: .gnaf, request: parameters)
                let aggregatedSearch = AggregatedSearch<Address>(requests: [request])
                let viewModel = MapSummarySearchResultViewModel(searchStrategy: strategy, title: searchable.text ?? "", aggregatedSearch: aggregatedSearch)
                viewModel.searchType = searchType
                return viewModel
            }
            strategy.onResultModelForSearchType = { searchType in
                switch searchType {
                case .radius(let coordinate, let radius):
                    let parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
                    let request = LocationMapSearchRequest(source: .gnaf, request: parameters)
                    let aggregatedSearch = AggregatedSearch<Address>(requests: [request])
                    let viewModel = MapSummarySearchResultViewModel(searchStrategy: strategy, title: String(format: "Pin dropped at (%.5f, %0.5f)", coordinate.latitude, coordinate.longitude), aggregatedSearch: aggregatedSearch)
                    viewModel.searchType = searchType
                    return viewModel
                }
            }

            let viewModel = EntitySummarySearchViewModel(title: "MPOL", dataSources: [
                PersonSearchDataSource(),
                VehicleSearchDataSource(),
                locationDataSource
            ])
            
            let searchViewController = SearchViewController(viewModel: viewModel)
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let actionListViewModel = EntitySummaryActionListViewModel()

            let actionListViewController = ActionListViewController(viewModel: actionListViewModel)
            actionListViewController.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let eventListVC = EventsListViewController()
            eventListVC.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let actionListNavController = UINavigationController(rootViewController: actionListViewController)
            let eventListNavController = UINavigationController(rootViewController: eventListVC)

            let tasksProxyViewController = AppProxyViewController(appUrlTypeScheme: CAD_APP_SCHEME)
            tasksProxyViewController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tab Bar Item title")
            tasksProxyViewController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)

            let tabBarController = UITabBarController()
            tabBarController.delegate = self
            tabBarController.viewControllers = [searchNavController, actionListNavController, eventListNavController, tasksProxyViewController]

            self.tabBarController = tabBarController

            // Set up entity summary and presentable
            let entityFormatter = EntitySummaryDisplayFormatter.default

            entityFormatter.registerEntityType(Person.self,
                                               forSummary: .function { return PersonSummaryDisplayable($0) },
                                               andPresentable: .function { return EntityScreen.entityDetails(entity: $0 as! Entity, delegate: searchViewController) })

            entityFormatter.registerEntityType(Vehicle.self,
                                               forSummary: .function { return VehicleSummaryDisplayable($0) },
                                               andPresentable: .function { return EntityScreen.entityDetails(entity: $0 as! Entity, delegate: searchViewController) })

            entityFormatter.registerEntityType(Address.self,
                                               forSummary: .function { return AddressSummaryDisplayable($0) },
                                               andPresentable: .function { return EntityScreen.entityDetails(entity: $0 as! Entity, delegate: searchViewController) })

            return tabBarController
        }
    }

    // MARK: - Private

    private weak var tabBarController: UIViewController?

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
        settingsNavController.modalPresentationStyle = .popover

        if let popoverController = settingsNavController.popoverPresentationController {
            popoverController.barButtonItem = item
        }

        tabBarController?.show(settingsNavController, sender: self)
    }
}

// MARK: - UITabBarControllerDelegate
extension LandingPresenter: UITabBarControllerDelegate {

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let appProxy = viewController as? AppProxyViewController {
            appProxy.launchApp()
            return false
        }
        return true
    }
}
