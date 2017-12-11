//
//  InteractivePopRecognizer.swift
//  MPOLKit
//
//  Created by Kyle May on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class InteractivePopRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    private let navigationController: UINavigationController?
    
    public init(controller: UINavigationController?) {
        self.navigationController = controller
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

