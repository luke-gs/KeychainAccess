//
//  AddressNavigationSelectionAction.swift
//  PublicSafetyKit
//
//  Created by Christian  on 14/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class AddressNavigationSelectionAction: SelectionAction {

    /// This must be called when the view controller is dismissed.
    public var dismissHandler: (() -> Void)?

    public let addressNavigatable: AddressNavigatable

    public var handler: AddressOptionHandler?

    public var actions: [ActionSheetButton]?

    public init(addressNavigatable: AddressNavigatable) {
        self.addressNavigatable = addressNavigatable
        if let coordinate = addressNavigatable.coordinate() {
            self.handler = AddressOptionHandler(coordinate: coordinate, address: addressNavigatable.fullAddress)
        } else {
            self.handler = nil
        }
    }

    /// The presentable to be displayed, or nil if explicit viewController should be used
    public func presentable(for sourceView: UIView?) -> Presentable? {
        guard let sourceView = sourceView,
            let coordinate = addressNavigatable.coordinate() else { return nil }
        return SystemScreen.addressLookup(source: sourceView, coordinate: coordinate, address: addressNavigatable.fullAddress, actions: actions)
    }

    /// The view controller to be displayed (if no presentable)
    ///
    /// - Returns: A view controller
    public func viewController() -> UIViewController {
        if let vc = handler?.actionSheetViewController(with: actions) {
            vc.modalPresentationStyle = .popover
            return vc
        }
        return UIViewController()
    }
}
