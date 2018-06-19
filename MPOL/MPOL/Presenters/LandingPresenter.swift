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
import PromiseKit

public enum Screen {
    case search
    case event
}

public class LandingPresenter: AppGroupLandingPresenter {

    public var searchViewController: SearchViewController!
    private var tasksProxyViewController: AppProxyViewController!

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
            let mode: LoginMode
            // This is the app wants to authenticate with biometric
            var retrievedUsername: String?
            if wantsBiometricAuthentication {
                // Check if the user wants to authenticate with biometric and it's possible.
                // Can't check for password, because the `password` would require user permission.
                if let currentUser = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain),
                    currentUser.useBiometric == .agreed {
                    mode = .usernamePasswordWithBiometric(delegate: self)
                    retrievedUsername = currentUser.username
                } else {
                    mode = .usernamePassword(delegate: self)
                }
            } else {
                mode = .usernamePassword(delegate: self)
            }

//            let loginViewController = LoginViewController(mode: mode)
//
//            loginViewController.minimumUsernameLength = 1
//            loginViewController.minimumPasswordLength = 1
//
//            #if DEBUG
//            loginViewController.usernameField.textField.text = "gridstone"
//            loginViewController.passwordField.textField.text = "mock"
//            #endif
//
//            if let username = retrievedUsername {
//                loginViewController.usernameField.textField.text = username
//            }

            let loginViewController = FancyLoginViewController(mode: mode)

            /// The version number
             var versionLabel: UILabel = {
                let label = UILabel(frame: .zero)
                label.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.bold)
                label.textColor = UIColor(white: 1.0, alpha: 0.64)

                if let info = Bundle.main.infoDictionary {
                    let version = info["CFBundleShortVersionString"] as? String ?? ""
                    let build   = info["CFBundleVersion"] as? String ?? ""

                    label.text = "Version \(version) #\(build)"
                }

                label.textAlignment = .right
                return label
            }()

            let imageView = UIImageView(image: #imageLiteral(resourceName: "GSMotoLogo"))
            imageView.contentMode = .bottomLeft

            let loginHeader = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                              subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

            let loginContainer = LoginContainerViewController()
            loginContainer.backgroundImage = #imageLiteral(resourceName: "Login")

            loginContainer.setHeaderView(loginHeader, at: .left)
            loginContainer.setFooterView(imageView, at: .left)
            loginContainer.setFooterView(versionLabel, at: .right)
            loginContainer.addContentViewController(loginViewController)

            return loginContainer

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
                let request = LocationMapSearchRequest(source: .pscore, request: parameters)
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
                let request = LocationMapSearchRequest(source: .pscore, request: parameters)
                let aggregatedSearch = AggregatedSearch<Address>(requests: [request])
                let viewModel = MapSummarySearchResultViewModel(searchStrategy: strategy, title: searchable.text ?? "", aggregatedSearch: aggregatedSearch)
                viewModel.searchType = searchType
                return viewModel
            }
            strategy.onResultModelForSearchType = { searchType in
                switch searchType {
                case .radius(let coordinate, let radius):
                    let parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
                    let request = LocationMapSearchRequest(source: .pscore, request: parameters)
                    let aggregatedSearch = AggregatedSearch<Address>(requests: [request])
                    let viewModel = MapSummarySearchResultViewModel(searchStrategy: strategy, title: String(format: "Pin dropped at (%.5f, %0.5f)", coordinate.latitude, coordinate.longitude), aggregatedSearch: aggregatedSearch)
                    viewModel.searchType = searchType
                    return viewModel
                }
            }

            let viewModel = EntitySummarySearchViewModel(title: "PSCore", dataSources: [
                PersonSearchDataSource(),
                VehicleSearchDataSource(),
                locationDataSource
                ])
            
            let searchViewController = SearchViewController(viewModel: viewModel)
            // Define a SearchNoContentView and add target to the tasksButton so that it opens CAD
            let searchNoContentView = SearchNoContentView()
            searchNoContentView.tasksButton.addTarget(self, action: #selector(openTasks), for: .touchUpInside)
            searchViewController.recentsViewController.viewModel.customNoContentView = searchNoContentView
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let eventsManager = EventsManager(eventBuilder: EventBuilder())
            let eventListVC = EventsListViewController(viewModel: EventsListViewModel(eventsManager: eventsManager))

            eventListVC.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let eventListNavController = UINavigationController(rootViewController: eventListVC)

            tasksProxyViewController = AppProxyViewController(appURLScheme: CAD_APP_SCHEME)
            tasksProxyViewController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tab Bar Item title")
            tasksProxyViewController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)

            let tabBarController = UITabBarController()
            tabBarController.delegate = self
            tabBarController.viewControllers = [searchNavController, eventListNavController, tasksProxyViewController]

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

            self.searchViewController = searchViewController
            self.tabBarController = tabBarController

            return tabBarController
        }
    }

    /// Custom post authentication logic that must be executed as part of authentication chain
    override open func postAuthenticateChain() -> Promise<Void> {
        return firstly {
            return APIManager.shared.fetchCurrentOfficerDetails(in: MPOLSource.pscore,
                                                                with: CurrentOfficerDetailsFetchRequest())
            }.done { officer in
                try! UserSession.current.userStorage?.add(object: officer,
                                                          key: UserSession.currentOfficerKey,
                                                          flag: UserStorageFlag.session)
        }
    }
    
    func switchTo(_ screen: Screen) {
        let selectedIndex: Int
        switch screen {
        case .search:
            selectedIndex = 0
        case .event:
            selectedIndex = 1
        }

        tabBarController?.selectedIndex = selectedIndex
    }

    // MARK: - Private

    public weak var tabBarController: UITabBarController?

    @objc private func settingsButtonItemDidSelect(_ item: UIBarButtonItem) {
        let settingsNavController = PopoverNavigationController(rootViewController: SettingsViewController())
        settingsNavController.modalPresentationStyle = .popover

        if let popoverController = settingsNavController.popoverPresentationController {
            popoverController.barButtonItem = item
        }

        tabBarController?.show(settingsNavController, sender: self)
    }

    @objc private func openTasks() {
        guard let controller = tabBarController else { return }
            _ = controller.delegate?.tabBarController?(controller, shouldSelect: tasksProxyViewController)
    }
}

// MARK: - UITabBarControllerDelegate
extension LandingPresenter: UITabBarControllerDelegate {

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let appProxy = viewController as? AppProxyViewController {
            appProxy.launch(AppLaunchActivity.open)
            return false
        }
        return true
    }
}
