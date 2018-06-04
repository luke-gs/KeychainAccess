//
//  PropertyDetailsPresenter.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal class PropertyDetailsPresenter {

    let containerViewController: Weak<PropertyDetailsViewController>
    let addPropertyView: Weak<UIView>
    let displayPropertyView: Weak<UIView>

    private var currentState: AddPropertyState = .add

    init(containerViewController: PropertyDetailsViewController,
         addPropertyView: UIView,
         displayPropertyView: UIView)
    {
        self.containerViewController = Weak(containerViewController)
        self.addPropertyView = Weak(addPropertyView)
        self.displayPropertyView = Weak(displayPropertyView)

        currentState = containerViewController.viewModel.report.property == nil ? .add : .display
        switchTo(currentState)
    }

    internal func switchTo(_ state: AddPropertyState) {
        guard let addPropertyView = addPropertyView.object else { return }
        guard let displayPropertyView = displayPropertyView.object else { return }
        guard let containerViewController = containerViewController.object else { return }

        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [addPropertyView, displayPropertyView] in
            addPropertyView.alpha = state == .add ? 1.0 : 0.0
            displayPropertyView.alpha = state == .display ? 1.0 : 0.0
        }

        animator.startAnimation()

        switch state {
        case .add:
            containerViewController.view.bringSubview(toFront: addPropertyView)
        case .display:
            containerViewController.view.bringSubview(toFront: displayPropertyView)
        }

        currentState = state
        updateNavigationBar()
    }

    internal func switchState() {
        switchTo(currentState == .add ? .display : .add)
    }

    // MARK: Private

    private func updateNavigationBar() {
        guard let containerViewController = containerViewController.object else { return }

        var rightItem: UIBarButtonItem?

        switch currentState {
        case .add:
            containerViewController.title = "Add Property"
            rightItem = nil
        case .display:
            containerViewController.title = "Create Details"
            rightItem = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: containerViewController,
                                        action: #selector(PropertyDetailsViewController.didTapOnDone))
        }

        containerViewController.navigationItem.rightBarButtonItem = rightItem
        containerViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                                   target: containerViewController,
                                                                                   action: #selector(UIViewController.dismissAnimated))
    }
}

internal enum AddPropertyState {
    case add
    case display
}
