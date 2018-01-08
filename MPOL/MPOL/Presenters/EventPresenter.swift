//
//  EventPresenter.swift
//  MPOL
//
//  Created by KGWH78 on 22/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public enum EventScreen: Presentable {
    case options(UIBarButtonItem)
    case draft
}

public class EventPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        guard let presentable = presentable as? EventScreen else { return UIViewController() }

        switch presentable {
        case .options(let barButtonItem):
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.popoverPresentationController?.barButtonItem = barButtonItem
            alertController.addAction(UIAlertAction(title: "New Event", style: .default, handler: { _ in

            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            return alertController
        case .draft:
            return UIViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        from.present(to, animated: true, completion: nil)
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is EventScreen.Type
    }

}
