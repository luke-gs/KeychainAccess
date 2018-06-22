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
            contentView.widthAnchor.constraint(equalToConstant: 420).withPriority(.almostRequired)
            
            ])

        contentView.setContentHuggingPriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.required, for: .vertical)
    }

    private func setupHeaderFooter() {
        let views = [
            headerViewLeft,
            headerViewCenter,
            headerViewRight,
            footerViewLeft,
            footerViewCenter,
            footerViewRight
        ]

        views.forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(maxMargin@600,>=minMargin@1000)-[hl][hc(<=hl@500)][hr(<=hc@200)]-(maxMargin@600,>=minMargin@900)-|",
                                                         options: [.alignAllTop],
                                                         metrics: ["maxMargin": 60,
                                                                   "minMargin": 32],
                                                         views: ["hl": headerViewLeft,
                                                                 "hc": headerViewCenter,
                                                                 "hr": headerViewRight])

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(maxMargin@600,>=minMargin@1000)-[fl][fc(<=fl@500)][fr(<=fc@200)]-(maxMargin@600,>=minMargin@900)-|",
                                                      options: [.alignAllBottom],
                                                      metrics: ["maxMargin": 60,
                                                                "minMargin": 32],
                                                      views: ["fl": footerViewLeft,
                                                              "fc": footerViewCenter,
                                                              "fr": footerViewRight])

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(maxMargin@600,>=minMargin@900)-[hvl(height@400)]->=16-[cv]->=16-[fvl(height@400)]-(maxMargin@600,>=minMargin@900)-|",
                                                      options: [],
                                                      metrics: ["maxMargin": 64,
                                                                "minMargin": 32,
                                                                "height": 60],
                                                      views: ["cv": contentView,
                                                              "hvl": headerViewLeft,
                                                              "fvl": footerViewLeft])

        constraints += [
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: headerViewLeft.leadingAnchor).withPriority(.required),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: headerViewRight.trailingAnchor).withPriority(.required)
        ]

        NSLayoutConstraint.activate(constraints)

        views.forEach{$0.setContentHuggingPriority(.required, for: .horizontal)}
    }
}

public enum LoginViewPosition {
    case left
    case center
    case right
}
