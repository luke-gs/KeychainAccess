//
//  LoadingState.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol LoadingState {
    var titleLabel: UILabel { get }
    var subtitleLabel: UILabel { get }
    var actionButton: RoundedRectButton { get }

    func appeared()

    func disappeared()

    func applyTheme(theme: Theme)
}

public protocol LoadingStateNoContent: LoadingState {
    var imageView: UIImageView { get }
}
