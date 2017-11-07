//
//  UIImageView+ImageLoadable.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// Extension on UIImageView to configure itself using `AsynchronousImageSizing`.
extension UIImageView {

    public func setImage(with imageLoadable: ImageLoadable) {
        let initialSizing = imageLoadable.sizing()
        apply(sizing: initialSizing)

        imageLoadable.loadImage { [weak self] sizeable in
            self?.apply(sizing: sizeable.sizing())
        }
    }

    private func apply(sizing: ImageSizing) {
        self.image = sizing.image
        if let contentMode = sizing.contentMode {
            self.contentMode = contentMode
        }
    }

}
