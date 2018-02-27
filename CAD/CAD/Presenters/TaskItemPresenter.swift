//
//  TaskItemPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class TaskItemPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! TaskItemScreen

        switch presentable {

        case .landing(let viewModel):
            return viewModel.createViewController()

        case .myCallsign:
            // Show split view controller for booked on resource
            let resource = CADStateManager.shared.currentResource!
            return ResourceTaskItemViewModel(resource: resource).createViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TaskItemScreen

        switch presentable {

        // Present form sheet
        case .landing(_), .myCallsign:
            if let splitNav = from.splitViewController?.navigationController {
                // Push new split view
                splitNav.pushViewController(to, animated: true)
            } else {
                // Present split view in nav (likely from form sheet)
                let nav = UINavigationController(rootViewController: to)
                from.present(nav, animated: true, completion: nil)
            }

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
