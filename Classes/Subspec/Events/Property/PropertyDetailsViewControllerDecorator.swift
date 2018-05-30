//
//  PropertyDetailsViewControllerDecorator.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

struct PropertyDetailsViewControllerDecorator {

    let addPropertyView: UIView
    let detailsScrollView: UIScrollView
    let stackView: UIStackView

    init(addPropertyView: UIView, detailsScrollView: UIScrollView, stackView: UIStackView) {
        self.addPropertyView = addPropertyView
        self.detailsScrollView = detailsScrollView
        self.stackView = stackView

        setupViews()
    }

    private func setupViews() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
    }

    func constrain(_ viewController: UIViewController) {
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
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        addPropertyView.addSubview(childViewController.view)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: addPropertyView.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: addPropertyView.bottomAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: addPropertyView.trailingAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: addPropertyView.leadingAnchor),
            ])
    }
}
