//
//  CollectionViewFormMPOLHeaderView.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class CollectionViewFormMPOLHeaderView: UICollectionReusableView {
    
    // MARK: - Public properties
    
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    public var separatorColor: UIColor? {
        get { return separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    public var allowsExpanding: Bool = false {
        didSet {
            if allowsExpanding != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    public var isExpanded: Bool {
        get { return _isExpanded }
        set { _isExpanded = newValue }
    }
    
    public func setExpanded(_ expanded: Bool, animated: Bool) {
        if _isExpanded == expanded { return }
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self._isExpanded = expanded
            }
        } else {
            _isExpanded = expanded
        }
    }
    
    
    // MARK: - Private properties
    
    fileprivate let separatorView = UIView(frame: .zero)
    
    fileprivate let arrowView = UIImageView(image: UIImage(named: "Arrow"))
    
    fileprivate var itemPosition: CGFloat = 0.0 {
        didSet { if fabs(itemPosition - oldValue) > 0.1 { setNeedsLayout() } }
    }
    
    fileprivate var separatorWidth: CGFloat = 0.0 {
        didSet { if fabs(separatorWidth - oldValue) > 0.1 { setNeedsLayout() } }
    }
    
    fileprivate var _isExpanded: Bool = false {
        didSet {
            if _isExpanded == oldValue { return }
            
            // TODO: Adjust rotation transform
        }
    }
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(arrowView)
        
        preservesSuperviewLayoutMargins = false
        
        separatorView.backgroundColor = Theme.current.colors[.Separator]
        updateFonts()
    }
    
}


extension CollectionViewFormMPOLHeaderView {
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? CollectionViewFormMPOLHeaderAttributes {
            separatorWidth = attributes.separatorWidth
            itemPosition   = attributes.itemPosition
            layoutMargins.left = attributes.leadingMargin
        } else {
            separatorWidth = UIScreen.main.singlePixelSize
            itemPosition   = bounds.maxY
            layoutMargins.left = 10.0
        }
        
        setNeedsLayout()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateFonts()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Layout subviews
    }
    
}

fileprivate extension CollectionViewFormMPOLHeaderView {
    
    fileprivate func updateFonts() {
        titleLabel.font = FontManager.shared.font(withStyle: .footnote2, compatibleWith: traitCollection)
        setNeedsLayout()
    }
    
}
