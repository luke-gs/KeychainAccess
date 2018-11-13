//
//  TaskItemPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

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
            return AddressOptionHandler(coordinate: coordinate, address: address).actionSheetViewController()
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

        case .landing:
            if let splitNav = from.pushableSplitViewController?.navigationController {
                // Push new split view
                splitNav.pushViewController(to, animated: true)
            } else {
                // Present split view in nav (likely from form sheet)
                let nav = UINavigationController(rootViewController: to)
                from.present(nav, animated: true, completion: nil)
            }

        case .resourceStatus:
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

        case .associationDetails:
            from.splitViewController?.navigationController?.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskItemScreen.Type
    }

}
