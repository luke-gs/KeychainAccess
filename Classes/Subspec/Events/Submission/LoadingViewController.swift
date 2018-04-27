//
//  LoadingViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class LoadingViewController<T>: ThemedPopoverViewController {

    public var builder: LoadingViewBuilder<T>? {
        didSet {
            loadingManager.loadingLabel.text = builder?.title
        }
    }

    private var loadingManager = LoadingStateManager()

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(builder: LoadingViewBuilder<T>? = nil) {
        self.builder = builder
        super.init(nibName: nil, bundle: nil)
        wantsTransparentBackground = false

        loadingManager.baseView = self.view
        loadingManager.state = .noContent
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        _ = builder?.promise?.ensure {
            self.dismissAnimated()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingManager.state = .loading
    }
}

public class LoadingViewBuilder<T> {
    var title: String?
    var subtitle: String?
    var promise: Promise<T>?
}
