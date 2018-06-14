//
//  LoadingStateLoadingView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A loading state view for representing the actual "Loading" state
open class LoadingStateLoadingView: BaseLoadingStateView {

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
        // Set default loading text
        titleLabel.text = NSLocalizedString("Loading", bundle: .mpolKit, comment: "Default loading title")

        // Add loading indicator to image container and always show
        let theme = ThemeManager.shared.theme(for: .current)
        loadingIndicatorView = MPOLSpinnerView(style: .large, color: theme.color(forKey: .tint))
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingIndicatorView)
        containerView.isHidden = false
        
        actionButton.tintColor = .clear
        actionButton.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .medium)
        actionButton.setTitleColor(.secondaryGray, for: .normal)
        actionButton.layer.borderColor = UIColor.secondaryGray.cgColor
        actionButton.layer.borderWidth = 1

        NSLayoutConstraint.activate([
            loadingIndicatorView.topAnchor.constraint(equalTo: containerView.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
    }

    public override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        loadingIndicatorView.color = theme.color(forKey: .tint)
    }

    public override func appeared() {
        loadingIndicatorView.play()
    }

    public override func disappeared() {
        loadingIndicatorView.stop()
    }
}

