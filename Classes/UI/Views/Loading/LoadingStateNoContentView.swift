//
//  LoadingStateNoContentView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var contentContext = 1

/// A loading state view for representing load complete but no content
open class LoadingStateNoContentView: BaseLoadingStateView, LoadingStateNoContent {

    // MARK: - Public properties
    
    /// The standard image view.
    public let imageView = UIImageView(frame: .zero)
    
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
        // Add image view to image container but only show if image is set
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        // Observe setting the image
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
    }
    
    deinit {
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
    }
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            switch object {
            case let imageView as UIImageView:
                containerView.isHidden = imageView.image == nil
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
