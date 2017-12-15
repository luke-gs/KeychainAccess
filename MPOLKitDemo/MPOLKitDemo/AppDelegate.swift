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

        EntitySummaryDisplayFormatter.default.registerEntityType(Person.self, forSummary: .function { return $0 as! EntitySummaryDisplayable }, andPresentable: .function { _ in return SystemScreen.serverError(title: "Nothing to see here", message: "Good bye.") })

        let theme = ThemeManager.shared.theme(for: .current)

        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(theme.image(forKey: .navigationBarBackground), for: .default)
        navBar.shadowImage = theme.image(forKey: .navigationBarShadow)
        navBar.barStyle  = theme.navigationBarStyle
        navBar.tintColor = theme.color(forKey: .navigationBarTint)

        let window = UIWindow()
        window.tintColor = theme.color(forKey: .tint)
        self.window = window

        let pushableSplitViewController = PushableSplitViewController(viewControllers: [UINavigationController(rootViewController: CollectionDemoListViewController(style: .grouped)), UINavigationController()])
        pushableSplitViewController.embeddedSplitViewController.maximumPrimaryColumnWidth = 320.0
        pushableSplitViewController.title = "Collections"
        let pushableSVNavController = UINavigationController(rootViewController: pushableSplitViewController)

        let sidebarDetail1VC = UIViewController()
        sidebarDetail1VC.title = "Sidebars"
        sidebarDetail1VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarInfo")
        sidebarDetail1VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarInfoFilled")

        let sidebarDetail2VC = CollectionDemoListViewController(style: .plain)
        sidebarDetail2VC.title = "Sidebar Test 2"
        sidebarDetail2VC.sidebarItem.image = #imageLiteral(resourceName: "SidebarAlert")
        sidebarDetail2VC.sidebarItem.selectedImage = #imageLiteral(resourceName: "SidebarAlertFilled")

        //        let item1 = SourceItem(title: "CRIMTRAC", state: .loaded(count: 8, color: .red))
        //        let item2 = SourceItem(title: "DS2", state: .loaded(count: 2, color: .blue))
        //        let item3 = SourceItem(title: "DS3", state: .loaded(count: 1, color: .yellow))

        let sidebarSplitViewController = SidebarSplitViewController(detailViewControllers: [sidebarDetail1VC, sidebarDetail2VC])
        //        sidebarSplitViewController.sidebarViewController.sourceItems = [item1, item2, item3]
        //        sidebarSplitViewController.sidebarViewController.selectedSourceIndex = 1
        sidebarSplitViewController.title = "Sidebars"

        let formSplitViewController = SidebarSplitViewController(detailViewControllers: examples)
        formSplitViewController.title = "Form Examples"
        formSplitViewController.selectedViewController = examples[8]

        let tabBarController = UITabBarController()

        UserSession.current.recentlySearched = [
            Searchable(text: "Jeff Kiedir", options: nil, type: "Person", imageKey: AssetManager.ImageKey.entityPerson),
            Searchable(text: "Scott Hocker", options: nil, type: "Person", imageKey: AssetManager.ImageKey.entityPerson),
            Searchable(text: "milah Ilreh", options: nil, type: "Vehicle", imageKey: AssetManager.ImageKey.entityCar),
            Searchable(text: "Jeff", options: nil, type: "Organisation", imageKey: AssetManager.ImageKey.entityBuilding),
            Searchable(text: "Heartsland Blvd", options: nil, type: "Location", imageKey: AssetManager.ImageKey.location)
        ]

        let recentlyViewed = UserSession.current.recentlyViewed
        recentlyViewed.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
            recentlyViewed.add([Person(), Person(), Person(), Person(), Person(), Person()])
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
                recentlyViewed.removeAll()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
                    recentlyViewed.add([Person(), Person()])
                }
            }
        }
        
        

        let recent = SearchRecentsViewController(viewModel: EntitySummaryRecentsViewModel(title: "Recents"))

        tabBarController.viewControllers = [
            UINavigationController(rootViewController: recent),
            pushableSVNavController,
            UINavigationController(rootViewController: sidebarSplitViewController),
            UINavigationController(rootViewController: SearchLookupAddressTableViewController(style: .plain)),
            UINavigationController(rootViewController: genericSearchViewController()),
            UINavigationController(rootViewController: formSplitViewController)
        ]

        tabBarController.selectedIndex = 0

        self.window?.rootViewController = tabBarController

        window.makeKeyAndVisible()

        return true
    }

    // MARK: Generic Search VC

    private func genericSearchViewController() -> UIViewController {

        // MARK: Generic Search VC
        let items1: [GenericSearchable] = Array(repeating: Test(), count: 2)
        let items2: [GenericSearchable] = Array(repeating: Test2(), count: 5)
        let items3: [GenericSearchable] = Array(repeating: Test3(), count: 3)

        let viewModel = GenericSearchDefaultViewModel(items: items1 + items2 + items3)
        viewModel.title = "Search Items"
        viewModel.collapsableSections = true
        viewModel.hasSections = false
        viewModel.hidesSections = false
        viewModel.sectionPriority = ["On Duty", "Duress", "On Air", "On Duty"]

        let vc = GenericSearchViewController(viewModel: viewModel)
        vc.title = "Search Items"
//        vc.delegate = self

        let nc = PopoverNavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .formSheet
        
        return vc
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

        let picker = PickerViewController()
        picker.sidebarItem.regularTitle = "Pickers"

        let stepper = StepperViewController()
        stepper.sidebarItem.regularTitle = "Steppers"
        
        let progress = ProgressViewController()
        progress.sidebarItem.regularTitle = "Progress"

        let date = DateViewController()
        date.sidebarItem.regularTitle = "Date"

        let personDetail = PersonDetailViewController()
        personDetail.sidebarItem.regularTitle = "Person Details"

        let results = ResultsViewController()
        results.sidebarItem.regularTitle = "Results"

        let signup = SignupViewController()
        signup.sidebarItem.regularTitle = "Signup"

        let subscription = SubscriptionViewController()
        subscription.sidebarItem.regularTitle = "Subscription"

        return [basic, list, custom, accessory, header, picker, stepper, progress, date, personDetail, results, signup, subscription]
    }()
}


// MAARK: Generic Search Demo searchables

struct Test: GenericSearchable {
    var title: String = "James"
    var subtitle: String? = "Neverdie"
    var section: String? = "On Duty"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test2: GenericSearchable {
    var title: String = "Herli"
    var subtitle: String? //= "Chad"
    var section: String? //= "On Air"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test3: GenericSearchable {
    var title: String = "Luke"
    var subtitle: String? = "Jimmy Boy"
    var section: String? = "Duress"
    var image: UIImage? = UIImage(named: "SidebarAlertFilled")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString) || (subtitle?.contains(searchString) ?? false)
    }
}
