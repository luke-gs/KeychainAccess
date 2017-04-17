//
//  SegmentedControlCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class SegmentedControlCollectionViewCell: CollectionViewFormCell {

    let segmentedControl = UISegmentedControl(items: nil)
    
    let infoButton = UIButton(type: .infoLight)
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        separatorStyle = .none
        
        let contentView = self.contentView
        
        let segmentedControl = self.segmentedControl
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        updateSegmentedControlForTraits()
        
        let infoButton = self.infoButton
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        contentView.addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: segmentedControl, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, priority: UILayoutPriorityDefaultHigh),
            NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY),
            NSLayoutConstraint(item: segmentedControl, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: contentView.layoutMarginsGuide, attribute: .leading),
            
            NSLayoutConstraint(item: infoButton, attribute: .leading,  relatedBy: .equal, toItem: segmentedControl, attribute: .trailing, constant: 16.0),
            NSLayoutConstraint(item: infoButton, attribute: .centerY,  relatedBy: .equal, toItem: segmentedControl, attribute: .centerY),
            NSLayoutConstraint(item: infoButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
        ])
    }
    
    
    // MARK: - Overrides
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            updateSegmentedControlForTraits()
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateSegmentedControlForTraits() {
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        
        segmentedControl.apportionsSegmentWidthsByContent = isCompact
        
        if traitCollection.horizontalSizeClass == .compact {
            segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)], for: .normal)
        } else {
            segmentedControl.setTitleTextAttributes(nil, for: .normal)
        }
    }
    
}
