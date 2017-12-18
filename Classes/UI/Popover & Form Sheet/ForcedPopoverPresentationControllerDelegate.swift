//
//  ForcedPopoverPresentationControllerDelegate.swift
//  MPOLKit
//
//  Created by Megan Efron on 19/12/17.
//

public class ForcedPopoverPresentationControllerDelegate: NSObject, UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
