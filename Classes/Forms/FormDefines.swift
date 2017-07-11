//
//  FormDefines.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// The standard separation value between title and detail labels.
internal let CellTitleSubtitleSeparation: CGFloat = 3.5


internal let iOSStandardSeparatorColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)

/// Key paths on UILabel that affect the intrinsic content size.
internal let keyPathsAffectingLabelLayout = [
    #keyPath(UILabel.text),
    #keyPath(UILabel.attributedText),
    #keyPath(UILabel.font),
    #keyPath(UILabel.numberOfLines)
]

/// Key paths on UIImageView that affect the intrinsic content size.
internal let keyPathsAffectingImageViewLayout = [
    #keyPath(UIImageView.image),
    #keyPath(UIImageView.animationImages),
    #keyPath(UIImageView.highlightedImage),
    #keyPath(UIImageView.isHighlighted),
]

