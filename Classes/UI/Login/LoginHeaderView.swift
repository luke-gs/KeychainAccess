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

    public convenience init(title: String, subtitle: String, image: UIImage) {
        self.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image
    }

    public override init(frame: CGRect) {

        super.init(frame: .zero)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "mPol"
        titleLabel.font = .systemFont(ofSize: 48.0, weight: UIFontWeightBold)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true


        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Mobile Policing Platform"
        subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFontWeightSemibold)
        subtitleLabel.textColor = .white
        subtitleLabel.adjustsFontSizeToFitWidth = true

        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[hi]-(==16@900)-[hl][sl]|", options: [.alignAllCenterX], metrics: nil, views: ["hi": imageView, "hl": titleLabel, "sl": subtitleLabel])
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX))
        NSLayoutConstraint.activate(constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
