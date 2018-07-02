//
//  LoginContainerViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// The Login container encompassing the headers and footers
///
/// Can provide your own content view controller
final public class LoginContainerViewController: UIViewController {

    // MARK: Start public interfaces

    /// The background image
    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }

    /// The left header view
    ///
    /// use `setHeaderView(_ view: UIView, at position: LoginViewPosition)` to set the header
    private(set) public var headerViewLeft = UIView()

    /// The center header view
    ///
    /// use `setHeaderView(_ view: UIView, at position: LoginViewPosition)` to set the header
    private(set) public var headerViewCenter = UIView()

    /// The right header view
    ///
    /// use `setHeaderView(_ view: UIView, at position: LoginViewPosition)` to set the header
    private(set) public var headerViewRight = UIView()

    /// The left footer view
    ///
    /// use `setFooterView(_ view: UIView, at position: LoginViewPosition)` to set the footer
    private(set) public var footerViewLeft = UIView()

    /// The center footer view
    ///
    /// use `setFooterView(_ view: UIView, at position: LoginViewPosition)` to set the footer
    private(set) public var footerViewCenter = UIView()

    /// The right footer view
    ///
    /// use `setFooterView(_ view: UIView, at position: LoginViewPosition)` to set the footer
    private(set) public var footerViewRight = UIView()

    /// The content view controller
    ///
    /// use `addContentViewController(_ contentViewController: UIViewController)` to set the content
    private(set) public var contentViewController: UIViewController?

    /// Add the content view controller
    /// This function will automatically do all viewController containment for you
    ///
    /// - Parameter contentViewController: your content view controller
    public func addContentViewController(_ contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        self.contentView = contentViewController.view
        addChildViewController(contentViewController)
        contentViewController.didMove(toParentViewController: self)
    }

    /// Set a view to one of the 3 available headers
    ///
    /// note: the maximum height of the header is 60.
    ///
    /// - Parameters:
    ///   - view: the view to set the header to
    ///   - position: which position to set the header to
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

    /// Set a view to one of the 3 available footers
    ///
    /// note: the maximum height of the footer is 60.
    ///
    /// - Parameters:
    ///   - view: the view to set the footer to
    ///   - position: which position to set the footer to
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

    // MARK: End public interfaces

    private var backgroundImageView = UIImageView()
    private var contentView = UIView()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupHeaderFooter()

        view.sendSubview(toBack: backgroundImageView)
        view.bringSubview(toFront: contentView)
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

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(maxMargin@600,>=minMargin@1000)-[hl]-[hc(<=hl@500)]-[hr(<=hc@400)]-(maxMargin@600,>=minMargin@1000)-|",
                                                         options: [.alignAllTop],
                                                         metrics: ["maxMargin": 60,
                                                                   "minMargin": 32],
                                                         views: ["hl": headerViewLeft,
                                                                 "hc": headerViewCenter,
                                                                 "hr": headerViewRight])

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "[fl]-[fc(<=fl@500)]-[fr(<=fc@400)]-(maxMargin@600,>=minMargin@1000)-|",
                                                      options: [.alignAllBottom],
                                                      metrics: ["maxMargin": 60,
                                                                "minMargin": 32],
                                                      views: ["fl": footerViewLeft,
                                                              "fc": footerViewCenter,
                                                              "fr": footerViewRight])

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(maxMargin@200,>=minMargin@1000)-[hvl(height@900)]->=16-[cv(>=120@900,500@500)]->=16-[fvl(height@900)]-(maxMargin@200,>=minMargin@900)-|",
                                                      options: [],
                                                      metrics: ["maxMargin": 64,
                                                                "minMargin": 32,
                                                                "height": 60],
                                                      views: ["cv": contentView,
                                                              "hvl": headerViewLeft,
                                                              "fvl": footerViewLeft])

        constraints += [
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: headerViewLeft.leadingAnchor).withPriority(.required),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: headerViewRight.trailingAnchor).withPriority(.required),
            footerViewLeft.leadingAnchor.constraint(equalTo: headerViewLeft.leadingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        views.forEach{$0.setContentHuggingPriority(.required, for: .horizontal)}
    }
}

/// The position of the headers and footer of the login container
///
/// - left: left view
/// - center: center view
/// - right: right view
public enum LoginViewPosition {
    case left
    case center
    case right
}
