//
//  CollectionViewFormProgressCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/3/17.
//
//

import UIKit

// TODO: At a later time this will need to be refactored for a different style,
// with the progress view below the content available.
open class CollectionViewFormProgressCell: CollectionViewFormValueFieldCell {

    public let progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
    
    override func commonInit() {
        super.commonInit()
        
        progressView.trackTintColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 0.25)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 2.0
        contentView.addSubview(progressView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleFrame = titleLabel.frame
        let valueFrame = valueLabel.frame
        
        let contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        var progressWidth = contentRect.width - (max(titleFrame.width, valueFrame.width) + 20.0)
        progressView.isHidden = progressWidth < 20.0
        progressWidth = max(20.0, progressWidth)
        
        let progressOriginX: CGFloat
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            progressOriginX = min(titleFrame.minX, valueFrame.minX) - 20.0 - progressWidth
        } else {
            progressOriginX = max(titleFrame.maxX, valueFrame.maxX) + 20.0
        }
        let progressOriginY = ((valueFrame.maxY + titleFrame.minY) / 2.0).floored(toScale: traitCollection.currentDisplayScale) - 1.0
        progressView.frame = CGRect(x: progressOriginX, y: progressOriginY, width: progressWidth, height: 2.0)
        
        // UIProgressView is annoying - it overrides setFrame: to deliberately block setting its height.
        // to fix this, do the above math with its required height of 2, and then go underneath to the layer
        // and adjust its size. Note: we do this within a CATransaction to avoid implicit animations from the
        // falsely set 2.0. It should always be 4.0
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressView.layer.bounds.size.height = 4.0
        CATransaction.commit()
    }
    
}
