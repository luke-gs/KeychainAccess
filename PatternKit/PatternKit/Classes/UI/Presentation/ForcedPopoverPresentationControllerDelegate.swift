//
//  ForcedPopoverPresentationControllerDelegate.swift
//  MPOLKit
//
//  Created by Megan Efron on 19/12/17.
//

public class ForcedPopoverPresentationControllerDelegate: NSObject, UIPopoverPresentationControllerDelegate {
    
    /// A strong reference to ourself as this is usually set to a weak delegate
    private var strongSelf: ForcedPopoverPresentationControllerDelegate?
    
    public override init() {
        super.init()
        // Retain strong reference
        strongSelf = self
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        // Remove the strong self reference now we have dismissed
        strongSelf = nil
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
