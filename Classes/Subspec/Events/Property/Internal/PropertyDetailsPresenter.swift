//
//  PropertyDetailsPresenter.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal struct PropertyDetailsPresenter {

    let containerViewController: PropertyDetailsViewController
    let addPropertyView: UIView
    let displayPropertyView: UIView

    private var currentState: AddPropertyState = .add

    init(containerViewController: PropertyDetailsViewController,
         addPropertyView: UIView,
         displayPropertyView: UIView)
    {
        self.containerViewController = containerViewController
        self.addPropertyView = addPropertyView
        self.displayPropertyView = displayPropertyView

        updateNavigationBar()
    }

    internal mutating func switchState() {
        currentState = currentState == .add ? .display : .add

        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [self, addPropertyView, displayPropertyView, currentState] in
            addPropertyView.alpha = currentState == .add ? 1.0 : 0.0
            displayPropertyView.alpha = currentState == .display ? 1.0 : 0.0

            self.updateNavigationBar()
        }
        animator.startAnimation()

        switch currentState {
        case .add:
            containerViewController.view.bringSubview(toFront: addPropertyView)
        case .display:
            containerViewController.view.bringSubview(toFront: displayPropertyView)
        }
    }

    private func updateNavigationBar() {
        var leftItem: UIBarButtonItem?
        var rightItem: UIBarButtonItem?

        switch currentState {
        case .add:
            containerViewController.title = "Add Property"
            leftItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                       target: containerViewController,
                                       action: #selector(UIViewController.dismissAnimated))
            rightItem = nil
        case .display:
            containerViewController.title = "Create Details"
            leftItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                       target: containerViewController,
                                       action: #selector(UIViewController.dismissAnimated))
            rightItem = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: containerViewController,
                                        action: #selector(PropertyDetailsViewController.didTapOnDone))
        }

        containerViewController.navigationItem.leftBarButtonItem = leftItem
        containerViewController.navigationItem.rightBarButtonItem = rightItem
    }
}

private enum AddPropertyState {
    case add
    case display
}
