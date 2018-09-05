//
//  LandingPresenter.swift
//  ClientKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit
import ClientKit
import PromiseKit

public enum Screen {
    case search
    case event
}

public class LandingPresenter: AppGroupLandingPresenter {

    public var searchViewController: SearchViewController!
    private var tasksProxyViewController: AppProxyViewController!

    override public var termsAndConditionsVersion: SemanticVersion {
        let version = SemanticVersion(TermsAndConditions.version)

        if version == nil {
            assertionFailure("termsAndConditionsVersion is not a valid semanticVersion")
        }
        return version!
    }

    override public var whatsNewVersion: SemanticVersion {
        let version = SemanticVersion(WhatsNew.version)

        if version == nil {
            assertionFailure("whatsNewVersion is not a valid semanticVersion")
        }
        return version!
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
            let acceptAction = DialogAction(title: NSLocalizedString("Accept", comment: "T&C - Accept"), handler: didAcceptConditions(_ :))
            let declineAction = DialogAction(title: NSLocalizedString("Decline", comment: "T&C - Decline"), handler: didDeclineConditions(_ :))

            do {
                let tsAndCsVC = try HTMLPresenterViewController(title: NSLocalizedString("Terms and Conditions", comment: "Title"),
                                                                htmlURL: TermsAndConditions.url,
                                                                actions: [declineAction, acceptAction])
                tsAndCsVC.title = "Terms and Conditions"

                let navController = ThemedNavigationController(rootViewController: tsAndCsVC)
                navController.modalPresentationStyle = .pageSheet
                return navController
            } catch {
                fatalError(error.localizedDescription)
            }

        case .whatsNew:
            let whatsNewVC = WhatsNewViewController(items: WhatsNew.detailItems)
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
                OrganisationSearchDataSource(),
                locationDataSource
                ])
            
            let searchViewController = SearchViewController(viewModel: viewModel)
            // Define a SearchNoContentView and add target to the tasksButton so that it opens CAD
            let searchNoContentView = SearchNoContentView()
            searchViewController.recentsViewController.viewModel.customNoContentView = searchNoContentView
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let eventsManager = EventsManager(eventBuilder: EventBuilder())
            let eventListVC = EventsListViewController(viewModel: EventsListViewModel(eventsManager: eventsManager))

            eventListVC.navigationItem.leftBarButtonItem = settingsBarButtonItem()

            let searchNavController = UINavigationController(rootViewController: searchViewController)
            let eventListNavController = UINavigationController(rootViewController: eventListVC)

            let bookOnViewController = self.bookOnViewController
            let taskingViewController = self.taskingViewController
            let activityLogViewController = self.activityLogViewController

            let tabBarController = UITabBarController()
            tabBarController.delegate = self
            tabBarController.viewControllers = [bookOnViewController, searchNavController, eventListNavController, taskingViewController, activityLogViewController]
            tabBarController.selectedViewController = searchNavController

            self.tabBarController = tabBarController

            // Set up entity summary and presentable
            let entityFormatter = EntitySummaryDisplayFormatter.default

            entityFormatter.registerEntityType(Person.self,
                                               forSummary: .function { return PersonSummaryDisplayable($0) },
                                               andPresentable: .function { return EntityScreen.entityDetails(entity: $0 as! Entity, delegate: searchViewController) })

            entityFormatter.registerEntityType(Vehicle.self,
                                               forSummary: .function { return VehicleSummaryDisplayable($0) },
                                               andPresentable: .function { return EntityScreen.entityDetails(entity: $0 as! Entity, delegate: searchViewController) })
            
            entityFormatter.registerEntityType(Organisation.self,
                                               forSummary: .function { return OrganisationSummaryDisplayable($0) },
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
        return super.postAuthenticateChain().then {
            // Sync all manifest items
            return Manifest.shared.fetchManifest(collections: nil)
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
    
    override public func onRemoteLogOffCompleted() {
        super.onRemoteLogOffCompleted()
        (UIApplication.shared.delegate as? AppDelegate)?.removeShortcuts()
    }
    
    func switchTo(_ screen: Screen) {
        let selectedIndex: Int
        switch screen {
        case .search:
            selectedIndex = 1
        case .event:
            selectedIndex = 2
        }

        tabBarController?.selectedIndex = selectedIndex
    }

    // MARK: - Tasking

    private var taskingViewController: UINavigationController {
        let taskListViewController = Director.shared.viewController(forPresentable: TaskListScreen.landing)

        let masterViewController = (taskListViewController as? MPOLSplitViewController)?.masterViewController
        masterViewController?.navigationItem.leftBarButtonItem = settingsBarButtonItem()

        let navigationController = UINavigationController(rootViewController: taskListViewController)
        navigationController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarTasks)
        navigationController.tabBarItem.selectedImage = AssetManager.shared.image(forKey: .tabBarTasksSelected)
        navigationController.tabBarItem.title = NSLocalizedString("Tasks", comment: "Tasks Tab Bar Item")
        return navigationController
    }

    private var activityLogViewController: UINavigationController {
        let activityLogViewModel = ActivityLogViewModel()

        let activityLogViewController = activityLogViewModel.createViewController()
        activityLogViewController.navigationItem.leftBarButtonItem = settingsBarButtonItem()

        let navigationController = UINavigationController(rootViewController: activityLogViewController)
        navigationController.tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActivity)
        navigationController.tabBarItem.selectedImage = AssetManager.shared.image(forKey: .tabBarActivitySelected)
        navigationController.tabBarItem.title = NSLocalizedString("Activity Log", comment: "Activity Log Tab Bar Item")
        return navigationController
    }

    private let userCallsignStatusViewModel = UserCallsignStatusViewModel()

    private lazy var bookOnViewController: UINavigationController = {
        userCallsignStatusViewModel.delegate = self

        let bookOnViewController = UIViewController()
        bookOnViewController.title = NSLocalizedString("Book On", comment: "Book On Screen Title")

        let navigationController = UINavigationController(rootViewController: bookOnViewController)

        if let item = navigationController.tabBarItem {
            item.title = userCallsignStatusViewModel.state.title
            item.image = userCallsignStatusViewModel.iconImage
        }

        return navigationController
    }()

    // MARK: - Private

    private func settingsBarButtonItem() -> UIBarButtonItem {
        let settingsItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .settings), style: .plain, target: self, action: #selector(settingsButtonItemDidSelect(_:)))
        settingsItem.accessibilityLabel = NSLocalizedString("Settings", comment: "SettingsIconAccessibility")
        return settingsItem
    }

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
            Settings.logOff
            ])

        let settingsVC = SettingsViewController(settingSections: [
            accessibilitySection,
            generalSection,
            pinnedSection
            ])

        let settingsNavController = PopoverNavigationController(rootViewController: settingsVC)
        settingsNavController.modalPresentationStyle = .formSheet
        settingsNavController.wantsDoneButton = false
        settingsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: settingsVC, action: #selector(UIViewController.dismissAnimated))

        tabBarController?.show(settingsNavController, sender: self)
    }
}

extension LandingPresenter: UserCallsignStatusViewModelDelegate {

    public func viewModelStateChanged() {
        if let item = bookOnViewController.tabBarItem {
            item.title = userCallsignStatusViewModel.state.title
            item.image = userCallsignStatusViewModel.iconImage
        }
    }

}


// MARK: - UITabBarControllerDelegate
extension LandingPresenter: UITabBarControllerDelegate {

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController == bookOnViewController {
            tabBarController.present(userCallsignStatusViewModel.screenForAction()!)
            return false
        }

        if let appProxy = viewController as? AppProxyViewController {
            appProxy.launch(AppLaunchActivity.open)
            return false
        }
        return true
    }

}
