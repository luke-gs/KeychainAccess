//
//  TaskItemPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit

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
            let buttons: [ActionSheetButton] = [
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
                    do {
                        try SearchActivityLauncher.default.launch(activity, using: AppURLNavigator.default)
                    }  catch {
                        AlertQueue.shared.addSimpleAlert(title: "An Error Has Occurred", message: "Failed To Launch Entity Search")
                    }
                })
            ]
            return ActionSheetViewController(buttons: buttons)
            
        case .associationDetails(let association):
            var ent: Entity?

            if let id = association.id, let entityType = association.entityType {
                switch entityType {
                case "Person":
                    ent = Person(id: id)
                case "Vehicle":
                    ent = Vehicle(id: id)
                case "Address":
                    ent = Address(id: id)
                default:
                    break
                }

                ent?.source = MPOLSource.pscore
            }

            if let entity = ent, let presentable = EntitySummaryDisplayFormatter.default.presentableForEntity(entity), let entityPresenter = (Director.shared.presenter as? PresenterGroup)?.presenters.first(where: { $0 is EntityPresenter }) {

                return entityPresenter.viewController(forPresentable: presentable)
            }

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

        case .associationDetails(_):
            from.splitViewController?.navigationController?.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
