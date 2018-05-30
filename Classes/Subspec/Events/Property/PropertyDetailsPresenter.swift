//
//  PropertyDetailsPresenter.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal enum AddPropertyState {
    case add
    case display
}

struct PropertyDetailsPresenter {

    let containerViewController: PropertyDetailsViewController
    let addPropertyView: UIView
    let displayPropertyView: UIView

    private(set) var currentState: AddPropertyState = .add

    init(containerViewController: PropertyDetailsViewController, addPropertyView: UIView, displayPropertyView: UIView) {
        self.containerViewController = containerViewController
        self.addPropertyView = addPropertyView
        self.displayPropertyView = displayPropertyView
    }

    internal mutating func switchState() {
        currentState = currentState == .add ? .display : .add

        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [addPropertyView, displayPropertyView, currentState] in
            addPropertyView.alpha = currentState == .add ? 1.0 : 0.0
            displayPropertyView.alpha = currentState == .display ? 1.0 : 0.0
        }
        animator.startAnimation()

        switch currentState {
        case .add:
            containerViewController.view.bringSubview(toFront: addPropertyView)
        case .display:
            containerViewController.view.bringSubview(toFront: displayPropertyView)
        }
    }
}
