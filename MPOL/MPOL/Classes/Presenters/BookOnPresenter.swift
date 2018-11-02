//
//  BookOnPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit

public class BookOnPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! BookOnScreen

        switch presentable {
        case .notBookedOn:
            return BookOnLandingViewModel().createViewController()

        case .manageBookOn:
            return ManageCallsignStatusViewModel().createViewController()

        case .callSignList:
            return CallsignListViewModel().createViewController()

        case .bookOnDetailsForm(let resource, _):
            return BookOnDetailsFormViewModel(resource: resource).createViewController()

        case .officerDetailsForm(let officerViewModel, let delegate):
            let viewModel = OfficerDetailsViewModel(officer: officerViewModel)
            viewModel.delegate = delegate
            return viewModel.createViewController()

        case .officerList(let detailsDelegate):
            let viewModel = OfficerListViewModel()
            viewModel.detailsDelegate = detailsDelegate
            return viewModel.createViewController()

        case .patrolAreaList(let current, let delegate, _):
            let viewModel = PatrolAreaListViewModel()
            viewModel.selectedPatrolArea = current
            viewModel.selectionDelegate = delegate
            return viewModel.createViewController()

        case .statusChangeReason(let completionHandler):
            // No view model, so use VC directly
            let vc = StatusChangeReasonViewController()
            vc.completionHandler = completionHandler
            return vc

        case .finaliseDetails(let primaryCode, let completionHandler):
            let viewModel = FinaliseDetailsViewModel(primaryCode: primaryCode)
            viewModel.completionHandler = completionHandler
            return viewModel.createViewController()
        }

    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! BookOnScreen

        switch presentable {

        // Form sheet popover presentation with adjusted background for all views in navigation controller
        case .notBookedOn, .manageBookOn:
            let container = ModalNavigationController(rootViewController: to)
            container.preferredContentSize = CGSize(width: 512, height: 650)
            from.presentModalViewController(container, animated: true, completion: nil)

        // Present form sheet with custom size
        case .statusChangeReason, .finaliseDetails:
            from.presentFormSheet(to, animated: true, size: CGSize(width: 448, height: 256), forced: true)

        // Present form sheet if not compact
        case .bookOnDetailsForm(_, let formSheet):
            if formSheet && !from.isCompact() {
                from.presentFormSheet(to, animated: true)
            } else {
                from.show(to, sender: from)
            }

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is BookOnScreen.Type
    }
}
