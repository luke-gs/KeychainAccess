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
    
    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; setNeedsLayout() }
    }
    
    public override var tintColor: UIColor! {
        get { return super.tintColor }
        set { super.tintColor = newValue }
    }
    
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
    
    public var isExpanded: Bool = false {
        didSet {
            if isExpanded == oldValue { return }
            
            // TODO: Adjust rotation transform
        }
    }
    
    public func setExpanded(_ expanded: Bool, animated: Bool) {
        if isExpanded == expanded { return }
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.isExpanded = expanded
            }
        } else {
            isExpanded = expanded
        }
    }
    
    public var tapHandler: ((CollectionViewFormMPOLHeaderView, IndexPath) -> (Void))?
    
    
    // MARK: - Private properties
    
    fileprivate let titleLabel: UILabel = UILabel(frame: .zero)
    
    fileprivate let separatorView = UIView(frame: .zero)
    
    fileprivate let arrowView = UIImageView(image: UIImage(named: "Arrow"))
    
    fileprivate var itemPosition: CGFloat = 0.0 {
        didSet { if fabs(itemPosition - oldValue) > 0.1 { setNeedsLayout() } }
    }
    
    fileprivate var separatorWidth: CGFloat = 0.0 {
        didSet { if fabs(separatorWidth - oldValue) > 0.1 { setNeedsLayout() } }
    }
    
    fileprivate var indexPath: IndexPath?
    
    
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
        
        titleLabel.text = "1 ACTIVE ALERT"
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
        
        preservesSuperviewLayoutMargins = false
        
        separatorView.backgroundColor = Theme.current.colors[.Separator]
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerDidRecognize)))
    }
    
}


extension CollectionViewFormMPOLHeaderView {
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        indexPath = layoutAttributes.indexPath
        
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let scale = (window?.screen ?? .main).scale
        
        var titleInset = layoutMargins.left
        
        if allowsExpanding {
            titleInset += 15.0
            
            // TODO: Set up drop down view.
        }
        
        let titleLabelSize = titleLabel.sizeThatFits(.zero)
        let titleLabelFrame = CGRect(origin: CGPoint(x: titleInset, y: (itemPosition - (separatorWidth / 2.0) - (titleLabelSize.height / 2.0)).rounded(toScale: scale)), size: titleLabelSize)
        
        titleLabel.frame = titleLabelFrame
        
        separatorView.frame = CGRect(x: titleLabelFrame.maxX + 7.0, y: itemPosition - separatorWidth, width: bounds.size.width - titleLabelFrame.maxX - 7.0, height: separatorWidth)
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }
    
}


fileprivate extension CollectionViewFormMPOLHeaderView {
    
    @objc fileprivate func tapGestureRecognizerDidRecognize() {
        if let indexPath = self.indexPath {
            tapHandler?(self, indexPath)
        }
    }
    
}
