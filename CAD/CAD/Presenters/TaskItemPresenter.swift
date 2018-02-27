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

        case .resourceStatus(let resource, let incident):
            let incidentItems = CADClientModelTypes.resourceStatus.incidentCases.map {
                return ManageCallsignStatusItemViewModel($0)
            }
            let sections = [CADFormCollectionSectionViewModel(title: "", items: incidentItems)]
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: resource.status, incident: incident)
            viewModel.showsCompactHorizontal = false
            return viewModel.createViewController()
        }

    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TaskItemScreen

        switch presentable {

        case .landing(_):
            if let splitNav = from.pushableSplitViewController?.navigationController {
                // Push new split view
                splitNav.pushViewController(to, animated: true)
            } else {
                // Present split view in nav (likely from form sheet)
                let nav = UINavigationController(rootViewController: to)
                from.present(nav, animated: true, completion: nil)
            }

        case .resourceStatus(_, _):
            // Present resource status form sheet with custom size and done button
            let size = from.isCompact() ? CGSize(width: 312, height: 224) : CGSize(width: 540, height: 120)
            to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(UIViewController.dismissAnimated))
            from.presentFormSheet(to, animated: true, size: size, forced: true)

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
