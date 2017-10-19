//
//  AppDelegate.swift
//  MPOLKitDemo
//
//  Created by Rod Brown on 15/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


import UIKit
import MPOLKit
import Unbox

private let host = "api-location-dev.mpol.solutions"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var delayedNetworkEndTimer: Timer?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidBegin), name: .NetworkActivityDidBegin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidEnd),   name: .NetworkActivityDidEnd,   object: nil)
        
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MPOLKitInitialize()

        APIManager.shared = APIManager(configuration: APIManagerDefaultConfiguration(url: "https://\(host)"))

//        let theme = ThemeManager.shared.theme(for: .current)
//
//        let navBar = UINavigationBar.appearance()
//        navBar.setBackgroundImage(theme.image(forKey: .navigationBarBackground), for: .default)
//        navBar.shadowImage = theme.image(forKey: .navigationBarShadow)
//        navBar.barStyle  = theme.navigationBarStyle
//        navBar.tintColor = theme.color(forKey: .navigationBarTint)
//
        let window = UIWindow()
//        window.tintColor = theme.color(forKey: .tint)
        self.window = window
//
//        let pushableSplitViewController = PushableSplitViewController(viewControllers: [UINavigationController(rootViewController: CollectionDemoListViewController(style: .grouped)), UINavigationController()])
//        pushableSplitViewController.embeddedSplitViewController.maximumPrimaryColumnWidth = 320.0
//        pushableSplitViewController.title = "Collections"
//        let pushableSVNavController = UINavigationController(rootViewController: pushableSplitViewController)
//
//        let sidebarDetail1VC = UIViewController()
//        sidebarDetail1VC.title = "Sidebars"
//        sidebarDetail1VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarInfo")
//        sidebarDetail1VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarInfoFilled")
//
//        let sidebarDetail2VC = CollectionDemoListViewController(style: .plain)
//        sidebarDetail2VC.title = "Sidebar Test 2"
//        sidebarDetail2VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarAlert")
//        sidebarDetail2VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarAlertFilled")
//
////        let item1 = SourceItem(title: "CRIMTRAC", state: .loaded(count: 8, color: .red))
////        let item2 = SourceItem(title: "DS2", state: .loaded(count: 2, color: .blue))
////        let item3 = SourceItem(title: "DS3", state: .loaded(count: 1, color: .yellow))
//
//        let sidebarSplitViewController = SidebarSplitViewController(detailViewControllers: [sidebarDetail1VC, sidebarDetail2VC])
////        sidebarSplitViewController.sidebarViewController.sourceItems = [item1, item2, item3]
////        sidebarSplitViewController.sidebarViewController.selectedSourceIndex = 1
//        sidebarSplitViewController.title = "Sidebars"
//
//        let formSplitViewController = SidebarSplitViewController(detailViewControllers: examples)
//        formSplitViewController.title = "Form Examples"
//
//        let tabBarController = UITabBarController()
//
//        tabBarController.viewControllers = [
//            pushableSVNavController,
//            UINavigationController(rootViewController: sidebarSplitViewController),
//            UINavigationController(rootViewController: SearchLookupAddressTableViewController(style: .plain)),
//            UINavigationController(rootViewController: formSplitViewController)
//        ]
//
//        tabBarController.selectedIndex = 3

        struct Test: GenericSearchable {
            var title: String = "Title 1"
            var subtitle: String = "Subtitle 1"
            var section: String = "Section 1"
            var image: UIImage = UIImage(named: "SidebarAlert")!

            func contains(searchString: String) -> Bool {
                return title.starts(with: searchString)
            }
        }

        struct Test2: GenericSearchable {
            var title: String = "Title 2"
            var subtitle: String = "Subtitle 2"
            var section: String = "Section 2"
            var image: UIImage = UIImage(named: "SidebarAlert")!

            func contains(searchString: String) -> Bool {
                return title.starts(with: searchString)
            }
        }

        struct Test3: GenericSearchable {
            var title: String = "Title 3"
            var subtitle: String = "Subtitle 3"
            var section: String = "Section 3"
            var image: UIImage = UIImage(named: "SidebarAlert")!

            func contains(searchString: String) -> Bool {
                return title.starts(with: searchString)
            }
        }

        let items1: [GenericSearchable] = Array(repeating: Test(), count: 10)
        let items2: [GenericSearchable] = Array(repeating: Test2(), count: 10)
        let items3: [GenericSearchable] = Array(repeating: Test3(), count: 10)

        var searchVM = GenericSearchViewModel(items: items1 + items2 + items3)
        searchVM.title = "Search Items"
        searchVM.expandableSections = true
        searchVM.delegate = self
        searchVM.sectionPriority = ["Section 2", "Section 1"]

        let vc = GenericSearchViewController(viewModel: searchVM)

        let nc = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = nc
        
        window.makeKeyAndVisible()
        
        return true
    }
    
    
    // MARK: - Network activity
    
    @objc private func networkActivityDidBegin() {
        delayedNetworkEndTimer?.invalidate()
        delayedNetworkEndTimer = nil
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @objc private func networkActivityDidEnd() {
        delayedNetworkEndTimer?.invalidate()
        delayedNetworkEndTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_: Timer) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.delayedNetworkEndTimer = nil
        }
    }

    private lazy var examples: [UIViewController] = {
        let basic = BasicViewController()
        basic.sidebarItem.regularTitle = "Basic"

        let list = ListViewController()
        list.sidebarItem.regularTitle = "List"

        let custom = CustomViewController()
        custom.sidebarItem.regularTitle = "Custom Items"

        let accessory = AccessoryViewController()
        accessory.sidebarItem.regularTitle = "Accessories"

        let header = HeaderViewController()
        header.sidebarItem.regularTitle = "Header Styles"

        let personDetail = PersonDetailViewController()
        personDetail.sidebarItem.regularTitle = "Person Details"

        let results = ResultsViewController()
        results.sidebarItem.regularTitle = "Results"

        let signup = SignupViewController()
        signup.sidebarItem.regularTitle = "Signup"

        let subscription = SubscriptionViewController()
        subscription.sidebarItem.regularTitle = "Subscription"

        return [basic, list, custom, accessory, header, personDetail, results, signup, subscription]
    }()
    
}

extension AppDelegate: GenericSearchDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Hello")
    }

    func genericSearchViewControllerDidSelectRow(at indexPath: IndexPath) {
        print("Hello \(indexPath)")
    }

//    func numberOfSections() -> Int {
//        return 2
//    }
//
//    func numberOfRows(in section: Int) -> Int {
//        return 10
//    }
//
//    func title(for section: Int) -> String {
//        return "Test Section \(section)"
//    }
//
//    func name(for indexPath: IndexPath) -> String {
//        return "Test Title \(indexPath.row)"
//    }
//
//    func description(for indexPath: IndexPath) -> String {
//        return "Test Description \(indexPath.row)"
//    }
//
//    func image(for indexPath: IndexPath) -> UIImage {
//        return UIImage(named: "SidebarAlert")!
//    }
}

            
    
