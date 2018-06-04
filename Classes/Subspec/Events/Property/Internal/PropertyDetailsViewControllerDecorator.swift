//
//  PropertyDetailsViewControllerDecorator.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal class PropertyDetailsViewControllerDecorator {

    let addPropertyView: Weak<UIView>
    let detailsScrollView: Weak<UIScrollView>
    let stackView: Weak<UIStackView>

    init(addPropertyView: UIView, detailsScrollView: UIScrollView, stackView: UIStackView) {
        self.addPropertyView = Weak(addPropertyView)
        self.detailsScrollView = Weak(detailsScrollView)
        self.stackView = Weak(stackView)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        apply(ThemeManager.shared.theme(for: .current))
    }

    func constrain(_ viewController: UIViewController) {
        guard let addPropertyView = addPropertyView.object else { return }
        guard let detailsScrollView = detailsScrollView.object else { return }
        guard let stackView = stackView.object else { return }

        addPropertyView.translatesAutoresizingMaskIntoConstraints = false
        detailsScrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.addSubview(detailsScrollView)
        viewController.view.addSubview(addPropertyView)
        detailsScrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            detailsScrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            detailsScrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            detailsScrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            detailsScrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),

            addPropertyView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            addPropertyView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            addPropertyView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            addPropertyView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),

            stackView.widthAnchor.constraint(equalTo: viewController.view.widthAnchor),
            stackView.topAnchor.constraint(equalTo: detailsScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: detailsScrollView.bottomAnchor)
            ])
    }

    func constrainChild(_ childViewController: UIViewController) {
        guard let addPropertyView = addPropertyView.object else { return }

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addPropertyView.addSubview(childViewController.view)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: addPropertyView.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: addPropertyView.bottomAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: addPropertyView.trailingAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: addPropertyView.leadingAnchor),
            ])
    }

    func apply(_ theme: Theme) {
        guard let detailsScrollView = detailsScrollView.object else { return }
        detailsScrollView.backgroundColor = theme.color(forKey: .background)
    }
}
