//
//  LoginHeaderView.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public final class LoginHeaderView: UIView {

    public let titleLabel: UILabel = UILabel()
    public let subtitleLabel: UILabel = UILabel()
    public let imageView: UIImageView = UIImageView()

    public convenience init(title: String?, subtitle: String?, image: UIImage?) {
        self.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image

        imageView.contentMode = .scaleAspectFit
    }

    public override init(frame: CGRect) {

        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
        subtitleLabel.textColor = .white
        subtitleLabel.adjustsFontSizeToFitWidth = true

        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        let views = ["hi": imageView, "hl": titleLabel, "sl": subtitleLabel]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[hi(48)]-[hl]->=0-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[hi(48)]->=0-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[hl][sl]->=0-|",
                                                      options: [.alignAllLeading, .alignAllTrailing],
                                                      metrics: nil,
                                                      views: views)
        NSLayoutConstraint.activate(constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
