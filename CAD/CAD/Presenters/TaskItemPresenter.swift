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

        case .resourceStatus(let initialStatus, let incident):
            let incidentItems = CADClientModelTypes.resourceStatus.incidentCases.map {
                return ManageCallsignStatusItemViewModel($0)
            }
            let sections = [CADFormCollectionSectionViewModel(title: "", items: incidentItems)]
            let viewModel = CallsignStatusViewModel(sections: sections, selectedStatus: initialStatus, incident: incident)
            viewModel.showsCompactHorizontal = false
            return viewModel.createViewController()

        case .addressLookup(_, let coordinate):
            return ActionSheetViewController(buttons: [
                ActionSheetButton(title: "Directions", icon: AssetManager.shared.image(forKey: .route), action: {
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                }),
                ActionSheetButton(title: "Street View", icon: AssetManager.shared.image(forKey: .streetView), action: nil),
                ActionSheetButton(title: "Search", icon: AssetManager.shared.image(forKey: .tabBarSearch), action: nil),
                ]
            )
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

        case .addressLookup(let source, _):
            if let to = to as? ActionSheetViewController {
                from.presentActionSheetPopover(to, sourceView: source, sourceRect: source.bounds, animated: true)
            }

        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
