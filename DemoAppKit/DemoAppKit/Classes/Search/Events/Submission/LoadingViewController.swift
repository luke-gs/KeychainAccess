//
//  LoadingViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// A loading view controller that presents a spinner
/// and executes the promise in the loading view builder
///
/// use with the `LoadingViewController` static function `presentWith(from:)`
open class LoadingViewController<T>: ThemedPopoverViewController {

    /// The loading view builder with generic type of expected response
    private(set) public var builder: LoadingViewBuilder<T>?
    private var loadingManager = LoadingStateManager()

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(builder: LoadingViewBuilder<T>? = nil) {
        self.builder = builder
        super.init(nibName: nil, bundle: nil)
        wantsTransparentBackground = false

        loadingManager.baseView = self.view
        loadingManager.state = .noContent
        loadingManager.loadingLabel.text = builder?.title

        _ = builder?.pendingPromise?.0.ensure {
            self.dismissAnimated()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingManager.state = .loading
    }
}

extension LoadingViewController {

    /// Present the loading view controller and attmept to fulfil the promise in the
    /// loading view builder
    ///
    /// will use the presenting view controllers content size is not specified in the `builder`
    ///
    /// - Parameters:
    ///   - builder: The loading view builder
    ///   - presentingViewController: The presenting view controller
    /// - Returns: The promise that will be fulfilled
    @discardableResult
    public static func presentWith(_ builder: LoadingViewBuilder<T>,
                                   from presentingViewController: UIViewController)
        -> Promise<T>? {
        let vc = LoadingViewController(builder: builder)
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .crossDissolve
        presentingViewController.present(vc, animated: true, completion: nil)

        if let size = builder.preferredContentSize {
            vc.preferredContentSize = size
        }

        builder.request?().done { result in
            builder.pendingPromise?.1.fulfill(result)
            }.catch { error in
                builder.pendingPromise?.1.reject(error)
        }
        return builder.pendingPromise?.0
    }
}

/// The loading view builder to be used with `LoadingViewController`
/// Provide the expected response as the generic type. `Void` if no response.
open class LoadingViewBuilder<Response> {

    /// The title to display while loading
    open var title: String?

    /// The subtitle to display while loading
    open var subtitle: String?

    /// the prefered content size of the view controller when presented
    open var preferredContentSize: CGSize?

    /// The request
    open var request: (() -> Promise<Response>)? {
        didSet {
            self.pendingPromise = Promise<Response>.pending()
        }
    }

    fileprivate var pendingPromise: (Promise<Response>, Resolver<Response>)?
    public init() { }
}
