//
//  LoadingView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A loading state view for representing the actual "Loading" state
open class LoadingView: BaseLoadingStateView {

    // MARK: - Public properties

    /// The standard loading indicator.
    open var loadingIndicatorView: MPOLSpinnerView!

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // Add loading indicator to image container and always show
        let theme = ThemeManager.shared.theme(for: .current)
        loadingIndicatorView = MPOLSpinnerView(style: .large, color: theme.color(forKey: .tint))
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.addSubview(loadingIndicatorView)
        imageContainerView.isHidden = false

        NSLayoutConstraint.activate([
            loadingIndicatorView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
        ])
    }
}

