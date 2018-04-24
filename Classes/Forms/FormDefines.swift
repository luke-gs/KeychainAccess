//
//  FormDefines.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// The standard vertical separation value between title and subtitle labels.
public let CellTitleSubtitleSeparation: CGFloat = 3.5

/// The standard vertical separation value between subtitle and detail labels.
public let CellSubtitleDetailSeparation: CGFloat = 8

/// The standard horizontal separation between images and labels.
public let CellImageLabelSeparation: CGFloat = 16.0

internal let iOSStandardSeparatorColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)

/// Key paths on UILabel that affect the layout.
internal let keyPathsAffectingLabelLayout = [
    #keyPath(UILabel.text),
    #keyPath(UILabel.attributedText),
    #keyPath(UILabel.font),
    #keyPath(UILabel.numberOfLines),
    #keyPath(UILabel.isHidden)
]

/// Key paths on UIImageView that affect the layout.
internal let keyPathsAffectingImageViewLayout = [
    #keyPath(UIImageView.image),
    #keyPath(UIImageView.animationImages),
    #keyPath(UIImageView.highlightedImage),
    #keyPath(UIImageView.isHighlighted),
    #keyPath(UIImageView.isHidden)
]

