//
//  TrafficStopPresenter.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class TrafficStopPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! BookOnTrafficStopScreen

        switch presentable {

        case .trafficStopEntity(let entityViewModel):
            return entityViewModel.createViewController()

        case .trafficStopSearchEntity:
            // Will redirect to search app, return dummy VC here
            return UIViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! BookOnTrafficStopScreen

        switch presentable {
        // Push
        case .trafficStopEntity(_):
            from.navigationController?.pushViewController(to, animated: true)

        // Search app
        case .trafficStopSearchEntity:
            from.dismiss(animated: true) {
                let activity = SearchActivity.searchEntity(term: Searchable(text: "", type: "Vehicle"))
                do {
                    try SearchActivityLauncher.default.launch(activity, using: AppURLNavigator.default)
                }  catch {
                    AlertQueue.shared.addSimpleAlert(title: "An Error Has Occurred", message: "Failed To Launch Entity Search")
                }
            }
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is BookOnTrafficStopScreen.Type
    }
}


