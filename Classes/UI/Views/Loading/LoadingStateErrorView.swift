//
//  LoadingStateErrorView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A loading state view for representing load failed
///
/// Currently this is just a content customised no content view
open class LoadingStateErrorView: LoadingStateNoContentView {

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
        // Set default error text
        titleLabel.text = NSLocalizedString("An error occured", bundle: .mpolKit, comment: "Default loading error title")

        // Set default loading failed image
        imageView.image = AssetManager.shared.image(forKey: .iconLoadingFailed)
    }
}
