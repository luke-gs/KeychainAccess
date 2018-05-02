//
//  LoadingViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class LoadingViewController<T>: ThemedPopoverViewController {
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

        let _ = builder?.pendingPromise?.0.ensure {
            self.dismissAnimated()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingManager.state = .loading
    }
}

extension LoadingViewController {
    @discardableResult
    public static func presentWith(_ builder: LoadingViewBuilder<T>,
                                   from presentingViewController: UIViewController)
        -> Promise<T>?
    {
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

open class LoadingViewBuilder<Response> {
    open var title: String?
    open var subtitle: String?
    open var preferredContentSize: CGSize?
    open var request: (() -> Promise<Response>)? {
        didSet {
            self.pendingPromise = Promise<Response>.pending()
        }
    }
    
    fileprivate var pendingPromise: (Promise<Response>, Resolver<Response>)?
    public init() { }
}
