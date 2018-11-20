//
//  SystemPresenter.swift
//  MPOLKit
//
//  Created by KGWH78 on 11/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PatternKit
import PublicSafetyKit

/// Supported presentable
public enum SystemScreen: Presentable {

    /// Alert controller with title and message and ok button
    case serverError(title: String, message: String)

    /// Address popover for "Directions, Street View, Search"
    case addressLookup(source: UIView, coordinate: CLLocationCoordinate2D?, address: String?)

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
        case .addressLookup(_, let coordinate, let address):
            return AddressOptionHandler(coordinate: coordinate, address: address).actionSheetViewController()

        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        let presentable = presentable as! SystemScreen

        switch presentable {
        case .serverError:
            AlertQueue.shared.add(to as! UIAlertController)
        case .addressLookup(let source, _, _):
            if let to = to as? ActionSheetViewController {
                from.presentActionSheetPopover(to, sourceView: source, sourceRect: source.bounds, animated: true)
            }


        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is SystemScreen.Type
    }

}
