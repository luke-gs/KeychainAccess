//
//  TaskItemPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit
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
            viewModel.displayMode = .regular
            return viewModel.createViewController()

        case .addressLookup(_, let coordinate, let address):
            return ActionSheetViewController(buttons: [
                ActionSheetButton(title: "Directions", icon: AssetManager.shared.image(forKey: .route), action: {
                    if let coordinate = coordinate {
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                        mapItem.name = address
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                    } else if let address = address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let url = URL(string: "http://maps.apple.com/?address=\(address)")
                    {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        AlertQueue.shared.addErrorAlert(message: "No valid location data was found")
                    }
                }),
                ActionSheetButton(title: "Street View", icon: AssetManager.shared.image(forKey: .streetView), action: nil),
                ActionSheetButton(title: "Search", icon: AssetManager.shared.image(forKey: .tabBarSearch), action: {
                    let activity = SearchActivity.searchEntity(term: Searchable(text: address, type: LocationSearchDataSourceSearchableType))
                    activity.launch()
                }),
                ]
            )
            
        case .associationDetails(_):
            // Will redirect to search app, return dummy VC here
            return UIViewController()

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
            let size = UIViewController.isWindowCompact() ? CGSize(width: 312, height: 224) : CGSize(width: 540, height: 150)
            if let vc = to as? CallsignStatusViewController {
                // Disable loading text for small modal dialog
                vc.loadingManager.loadingView.titleLabel.text = nil
            }
            from.presentFormSheet(to, animated: true, size: size, forced: true)

        case .addressLookup(let source, _, _):
            if let to = to as? ActionSheetViewController {
                from.presentActionSheetPopover(to, sourceView: source, sourceRect: source.bounds, animated: true)
            }

        case .associationDetails(let association):
            if let id = association.id, let entityType = association.entityType, let source = association.source {
                let activity = SearchActivity.viewDetails(id: id, entityType: entityType, source: source)
                activity.launch()
            }

        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
