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

            // Check if the user wants to authenticate with biometric and it's possible.
            // Can't check for password, because the `password` would require user permission.
            var retrievedUsername: String?
            if wantsBiometricAuthentication {
                if let currentUser = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain),
                    currentUser.useBiometric == .agreed {
                    mode = .credentialsWithBiometric(delegate: self)
                    retrievedUsername = currentUser.username
                } else {
                    mode = .credentials(delegate: self)
                }
            } else {
                mode = .credentials(delegate: self)
            }

            let loginViewController = LoginViewController(mode: mode)
            loginViewController.setupDefaultStyle(with: retrievedUsername)

            let loginContainer = LoginContainerViewController()
            loginContainer.setupDefaultStyle()

            loginContainer.addContentViewController(loginViewController)

            return loginContainer

        case .termsAndConditions:
            let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
            tsAndCsVC.delegate = self
            let navController = PopoverNavigationController(rootViewController: tsAndCsVC)
            navController.modalPresentationStyle = .formSheet

            return navController

        case .whatsNew:
            let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
                                                       detail: """
[MPOLA-1584] - Update Login screen to remove highlighting in T&Cs and forgot password.
[MPOLA-1565] - Use manifest for event entity relationships.
[MPOLA-1568] - Pin the logout button to the bottom
[MPOLA-1597] - Update presentation for Terms and Conditions from Settings
[MPOLA-1597] - Update presentation for What's New from Settings
[MPOLA-1597] - Add basic signature capture from Settings

""")
            let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage])
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
            // Sync manifest items used in search app
            return Manifest.shared.fetchManifest(collections: ManifestCollection.searchCollections)
            }.then { _ in
                // Fetch the current officer details
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
        let accessibilitySection: SettingSection = SettingSection(type: .plain(title: "Accessibility"), settings: [
            Settings.numericKeyboard,
            Settings.darkMode,
            Settings.biometrics,
            Settings.signature
            ])
        let generalSection: SettingSection = SettingSection(type: .plain(title: "General"), settings: [
            Settings.manifest,
            Settings.support,
            Settings.termsAndConditions,
            Settings.whatsNew
            ])
        let pinnedSection: SettingSection = SettingSection(type: .pinned, settings: [
            Settings.logOut
            ])

        let settingsVC = SettingsViewController(settingSections: [
            accessibilitySection,
            generalSection,
            pinnedSection
            ])

        let settingsNavController = ThemedNavigationController(rootViewController: settingsVC)
        settingsNavController.modalPresentationStyle = .formSheet
        settingsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: settingsVC, action: #selector(UIViewController.dismissAnimated))

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
