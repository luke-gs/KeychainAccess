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

    private(set) var headerViewLeft = UIView()
    private(set) var headerViewCenter = UIView()
    private(set) var headerViewRight = UIView()

    private(set) var footerViewLeft = UIView()
    private(set) var footerViewCenter = UIView()
    private(set) var footerViewRight = UIView()

    private(set) var contentViewController: UIViewController?

    private var backgroundImageView = UIImageView()
    private var contentView = UIView()

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupHeaderFooter()
        view.sendSubview(toBack: backgroundImageView)
        view.bringSubview(toFront: contentView)
    }

    public func addContentViewController(_ contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        self.contentView = contentViewController.view
        addChildViewController(contentViewController)
        contentViewController.didMove(toParentViewController: self)
    }

    public func setHeaderView(_ view: UIView, at position: LoginViewPosition) {
        switch position {
        case .left:
            headerViewLeft = view
        case .center:
            headerViewCenter = view
        case .right:
            headerViewRight = view
        }
        view.clipsToBounds = true
    }

    public func setFooterView(_ view: UIView, at position: LoginViewPosition) {
        switch position {
        case .left:
            footerViewLeft = view
        case .center:
            footerViewCenter = view
        case .right:
            footerViewRight = view
        }
        view.clipsToBounds = true
    }

    // MARK: Private
    private func setupViews() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundImageView)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).withPriority(.required),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).withPriority(.required),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300).withPriority(.required),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: 420)
            
            ])

        contentView.setContentHuggingPriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.required, for: .vertical)
    }

    private func setupHeaderFooter() {
        let headers = [
            headerViewLeft,
            headerViewCenter,
            headerViewRight,
            ]

        let footers = [
            footerViewLeft,
            footerViewCenter,
            footerViewRight,
            ]

        (headers+footers).forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[hl][hc(<=hl)][hr(<=hc)]-60-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["hl": headerViewLeft,
                                                                 "hc": headerViewCenter,
                                                                 "hr": headerViewRight])


        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[fl][fc(<=fl)][fr(<=fc)]-60-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["fl": footerViewLeft,
                                                              "fc": footerViewCenter,
                                                              "fr": footerViewRight])

        constraints += headers.map{$0.topAnchor.constraint(equalTo: view.topAnchor, constant: 64)}
        constraints += headers.map{$0.heightAnchor.constraint(lessThanOrEqualToConstant: 60)}

        constraints += footers.map{$0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64)}
        constraints += footers.map{$0.heightAnchor.constraint(lessThanOrEqualToConstant: 60)}
        constraints += footers.map{$0.topAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -16)}

        NSLayoutConstraint.activate(constraints)
    }
}

public enum LoginViewPosition {
    case left
    case center
    case right
}
