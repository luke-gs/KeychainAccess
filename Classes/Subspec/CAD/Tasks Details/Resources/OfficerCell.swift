//
//  OfficerCell.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Custom form cell for displaying an officer.
///
/// This uses the standard CollectionViewFormSubtitleCell, but adds a badge label
/// and buttons for comms
open class OfficerCell: CollectionViewFormSubtitleCell {
    
    /// Badge label
    public let badgeLabel = RoundedRectLabel(frame: .zero)
    
    private let buttonsView = UIView(frame: .zero)
    public let messageButton = UIButton(frame: .zero)
    public let callButton = UIButton(frame: .zero)
    public let videoButton = UIButton(frame: .zero)
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let badgeColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        badgeLabel.backgroundColor = .clear
        badgeLabel.borderColor = badgeColor
        badgeLabel.textColor = badgeColor
        addSubview(badgeLabel)
        
        addSubview(buttonsView)
        
        // TODO: Get real image
        messageButton.setImage(AssetManager.shared.image(forKey: .email), for: .normal)
        messageButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)  
        buttonsView.addSubview(messageButton)
        
        callButton.setImage(AssetManager.shared.image(forKey: .audioCall), for: .normal)
        callButton.contentMode = .scaleAspectFit
        callButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)
        buttonsView.addSubview(callButton)
        
        videoButton.setImage(AssetManager.shared.image(forKey: .videoCall), for: .normal)
        videoButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)
        buttonsView.addSubview(videoButton)
        
        imageAlignment = .title
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Size label to make space for it
        badgeLabel.sizeToFit()
        
        badgeLabel.frame = CGRect(x: titleLabel.frame.maxX + 10,
                                 y: titleLabel.frame.origin.y,
                                 width: badgeLabel.frame.width,
                                 height: badgeLabel.frame.height)

        let imageSize: CGFloat = 24
        let buttonViewSize: CGFloat = imageSize * 5 // 3 images plus 2 padding between
        
        buttonsView.frame = CGRect(x: frame.maxX - buttonViewSize - imageSize, y: frame.height / 2 - imageSize / 2, width: buttonViewSize, height: imageSize)
        messageButton.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        callButton.frame = CGRect(x: messageButton.frame.maxX + imageSize, y: 0, width: imageSize, height: imageSize)
        videoButton.frame = CGRect(x: callButton.frame.maxX + imageSize, y: 0, width: imageSize, height: imageSize)
    }
}
