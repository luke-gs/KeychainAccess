//
//  BookOnPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class BookOnPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! BookOnScreen

        switch presentable {
        case .notBookedOn:
            return NotBookedOnViewModel().createViewController()

        case .manageBookOn:
            return ManageCallsignStatusViewModel().createViewController()

        case .callSignList:
            return CallsignListViewModel().createViewController()

        case .bookOnDetailsForm(let callsignViewModel):
            return BookOnDetailsFormViewModel(callsignViewModel: callsignViewModel).createViewController()

        case .officerDetailsForm(let officerViewModel, let delegate):
            let viewModel = OfficerDetailsViewModel(officer: officerViewModel)
            viewModel.delegate = delegate
            return viewModel.createViewController()

        case .officerList(let detailsDelegate):
            let viewModel = OfficerListViewModel()
            viewModel.detailsDelegate = detailsDelegate
            return viewModel.createViewController()

        case .patrolAreaList(let current, let delegate):
            let viewModel = PatrolAreaListViewModel()
            viewModel.selectedPatrolArea = current
            viewModel.delegate = delegate
            return viewModel.createViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! BookOnScreen

        switch presentable {

        // Form sheet popover presentation with adjusted background for all views in navigation controller
        case .notBookedOn: fallthrough
        case .manageBookOn:
            let container = PopoverNavigationController(rootViewController: to)
            container.modalPresentationStyle = .formSheet
            container.lightTransparentBackground = UIColor(white: 1, alpha: 0.5)
            from.present(container, animated: true)

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is BookOnScreen.Type
    }

}
