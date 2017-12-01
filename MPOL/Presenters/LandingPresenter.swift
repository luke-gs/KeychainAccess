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

#if !EXTERNAL
import EndpointManager
#endif

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
            let loginViewController = LoginViewController()

            loginViewController.minimumUsernameLength = 1
            loginViewController.minimumPasswordLength = 1

            loginViewController.backgroundImage = #imageLiteral(resourceName: "Login")
            loginViewController.headerView = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                                             subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

            loginViewController.delegate = self

            #if DEBUG
                loginViewController.usernameField.text = "matt"
                loginViewController.passwordField.text = "vicroads"
            #endif

            #if !EXTERNAL
                let configButton = UIButton(type: .system)
                configButton.setImage(#imageLiteral(resourceName: "endpoint"), for: .normal)
                configButton.setTitle(EndpointManager.selectedEndpoint?.name, for: .normal)
                configButton.addTarget(self, action: #selector(showEndpointManager), for: .touchUpInside)

                loginViewController.leftAccessoryView = configButton
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

            let viewModel = MPOLSearchViewModel()

            let searchViewController = SearchViewController(viewModel: viewModel)
            searchViewController.set(leftBarButtonItem: settingsBarButtonItem())

            let actionListViewModel = EntitySummaryActionListViewModel {
                switch $0 {
                case is Person: return (PersonSummaryDisplayable($0), viewModel.presentable(for: $0))
                case is Vehicle: return (VehicleSummaryDisplayable($0), viewModel.presentable(for: $0))
                default: return nil
                }
            }

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

    @objc private func showEndpointManager() {
        #if !EXTERNAL
        EndpointManager.presentEndpointManagerFrom(UIApplication.shared.keyWindow!)
        #endif
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
