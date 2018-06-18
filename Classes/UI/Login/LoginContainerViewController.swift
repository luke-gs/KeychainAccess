//
//  LoginContainerViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

final public class LoginContainerViewController: UIViewController {

    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }

    private(set) var headerContainer = UIView()
    private(set) var footerContainer = UIView()
    private(set) var contentViewController: UIViewController?

    private var backgroundImageView = UIImageView()
    private var contentView = UIView()

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    public func addContentViewController(_ contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        self.contentView = contentViewController.view
        addChildViewController(contentViewController)
        contentViewController.didMove(toParentViewController: self)
    }

    public func addHeaderView(_ view: UIView) {
        headerContainer = view
    }

    public func addFooterView(_ view: UIView) {
        footerContainer = view
    }

    // MARK: Private
    private func setupViews() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundImageView)
        view.addSubview(headerContainer)
        view.addSubview(footerContainer)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            headerContainer.heightAnchor.constraint(equalToConstant: 60),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),

            footerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            footerContainer.heightAnchor.constraint(equalToConstant: 60),
            footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),

            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 64),
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -64)
            ])

        view.sendSubview(toBack: backgroundImageView)
    }
}

open class FancyLoginHeaderView: UIView {

    private var stackView = UIStackView()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init() {
        super.init(frame: .zero)
        setupViews()
        setupStackView()
    }

    public func addToStackView(_ subview: UIView) {
        stackView.addArrangedSubview(subview)
    }

    // MARK: Private

    private func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
    }


    private func setupStackView() {
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
    }
}

open class FancyLoginFooterView: UIView {

    private var stackView = UIStackView()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init() {
        super.init(frame: .zero)
        setupViews()
        setupStackView()
    }


    public func addToStackView(_ subview: UIView) {
        stackView.addArrangedSubview(subview)
    }

    // MARK: Private

    private func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
    }

    private func setupStackView() {
        stackView.alignment = .trailing
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
    }
}
