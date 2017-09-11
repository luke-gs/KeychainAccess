//
//  SystemPresenter.swift
//  MPOLKit
//
//  Created by KGWH78 on 11/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Supported presentable
public enum SystemScreen: Presentable {

    /// Alert controller with title and message and ok button
    case serverError(title: String, message: String)

}


public class SystemPresenter: Presenter {

    public init() { }

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        guard let presentable = presentable as? SystemScreen else { return UIViewController() }

        switch presentable {
        case .serverError(let title, let message):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert - OK"), style: .cancel, handler: nil))
            return alertController
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        let presentable = presentable as! SystemScreen

        switch presentable {
        case .serverError:
            AlertQueue.shared.add(to as! UIAlertController)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is SystemScreen.Type
    }

}
