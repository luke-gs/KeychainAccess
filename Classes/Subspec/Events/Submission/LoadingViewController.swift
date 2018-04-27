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
        presentingViewController.present(vc, animated: true, completion: nil)

        builder.request?().done { result in
            builder.pendingPromise?.1.fulfill(result)
            }.catch { error in
                builder.pendingPromise?.1.reject(error)
        }
        return builder.pendingPromise?.0
    }
}

public class LoadingViewBuilder<Response> {
    fileprivate var pendingPromise: (Promise<Response>, Resolver<Response>)?

    public var title: String?
    public var subtitle: String?
    public var request: (() -> Promise<Response>)? {
        didSet {
            self.pendingPromise = Promise<Response>.pending()
        }
    }

    public init() { }
}
