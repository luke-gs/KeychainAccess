//
//  MediaPreviewableCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Basic cell to display media item. Subclass can extend this and provide custom layout.
///
/// This cell only contains an image view, and automatically request image on setting the media item.
open class MediaPreviewableCell: UICollectionViewCell, DefaultReusable {

    open let imageView = UIImageView(frame: .zero)

    open var media: MediaPreviewable? {
        didSet {
            guard media !== oldValue else { return }
            if let media = media {
                media.thumbnailImage?.requestImage(completion: { [weak self] (image) in
                    guard let `self` = self else { return }
                    if self.media === media {
                        self.imageView.image = image.sizing().image
                    }
                })

                imageView.contentMode = media.thumbnailImage?.sizing().contentMode ?? .scaleAspectFill
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.backgroundColor = .gray
        imageView.tintColor = .white
        contentView.addSubview(imageView)

        contentView.layer.cornerRadius = 4.0
        contentView.clipsToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
