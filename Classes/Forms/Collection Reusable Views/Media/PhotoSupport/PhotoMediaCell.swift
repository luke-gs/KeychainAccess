//
//  PhotoMediaCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class PhotoMediaCell: MediaPreviewableCell, MediaPreviewRenderer {

    public typealias Media = PhotoMedia

    public override var media: MediaPreviewable? {
        didSet {
            guard let media = media as? Media else { return }
            sensitive = media.sensitive
        }
    }

    public var sensitive: Bool = false {
        didSet {
            if sensitive {
                if let effectView = effectView {
                    effectView.isHidden = false
                } else {
                    let label = UILabel(frame: bounds)
                    label.text = NSLocalizedString("Sensitive", comment: "Preview - Sensitive Data")
                    label.textAlignment = .center
                    label.textColor = .white
                    label.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
                    label.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
                    label.numberOfLines = 0

                    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
                    effectView.frame = bounds
                    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                    effectView.contentView.addSubview(label)
                    contentView.addSubview(effectView)

                    self.effectView = effectView
                }
            } else {
                effectView?.isHidden = true
            }
        }
    }

    private var effectView: UIVisualEffectView?

}
