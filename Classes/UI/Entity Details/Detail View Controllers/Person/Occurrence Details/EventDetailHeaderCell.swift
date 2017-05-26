//
//  EventDetailHeaderCell.swift
//  Pods
//
//  Created by Rod Brown on 25/5/17.
//
//

import UIKit

open class EventDetailHeaderCell: CollectionViewFormSubtitleCell {
    
    open class func minimumContentHeight(withTitle title: String?, subtitle: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        return super.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: width, compatibleWith: traitCollection, emphasis: .title, titleFont: .systemFont(ofSize: 28.0, weight: UIFontWeightBold), singleLineTitle: false) + 15.0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
    }
    
    
}
