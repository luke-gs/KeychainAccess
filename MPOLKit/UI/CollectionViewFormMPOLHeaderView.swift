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
    
    /// The text for the MPOL header.
    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; setNeedsLayout() }
    }
    
    
    /// The tint color for the view. The text and optional expansion icon will be tinted this color.
    public override var tintColor: UIColor! {
        get { return super.tintColor }
        set { super.tintColor = newValue }
    }
    
    
    /// The separator color.
    public var separatorColor: UIColor? {
        get { return separatorView.backgroundColor }
        set { separatorView.backgroundColor = newValue }
    }
    
    
    /// A boolean value indicating whether the view should display an expand arrow.
    /// 
    /// The default is `false`.
    public var showsExpandArrow: Bool = false {
        didSet {
            if showsExpandArrow == oldValue { return }
            
            arrowView.isHidden = !showsExpandArrow
            setNeedsLayout()
        }
    }
    
    
    /// A boolean value indicating whether the expand arrow should be in an expanded state.
    ///
    /// The default is `false`. Setting this updates without an animation.
    public var isExpanded: Bool = false {
        didSet {
            if isExpanded != oldValue {
                arrowView.transform = isExpanded ? .identity : CGAffineTransform(rotationAngle: -0.5 * CGFloat.pi)
            }
        }
    }

    
    /// Updates the isExpanded property, optionally with animation.
    ///
    /// - Parameters:
    ///   - expanded: A boolean value indicating whether the header should be expanded.
    ///   - animated: A boolean value indicating whether the update should be animated.
    public func setExpanded(_ expanded: Bool, animated: Bool) {
        if isExpanded == expanded { return }
        
        if animated {
            UIView.animate(withDuration: 0.15) {
                self.isExpanded = expanded
            }
        } else {
            isExpanded = expanded
        }
    }
    
    
    /// An optional tap handler closure, passing the header view itself, and the associated
    /// index path.
    public var tapHandler: ((CollectionViewFormMPOLHeaderView, IndexPath) -> (Void))?
    
    
    // MARK: - Private properties
    
    fileprivate let titleLabel    = UILabel(frame: .zero)
    
    fileprivate let separatorView = UIView(frame: .zero)
    
    fileprivate let arrowView     = UIImageView(image: UIImage(named: "DropDown", in: Bundle(for: CollectionViewFormMPOLHeaderView.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
    
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
        
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
        
        separatorView.backgroundColor = Theme.current.colors[.Separator]
        
        arrowView.transform = CGAffineTransform(rotationAngle: -0.5 * CGFloat.pi)
        arrowView.isHidden = true
        
        preservesSuperviewLayoutMargins = false
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerDidRecognize)))
    }
    
}


// MARK: - Sizing
/// Sizing
extension CollectionViewFormMPOLHeaderView {
    
    public static let minimumHeight: CGFloat = 20.0
    
}


// MARK: - Overrides
/// Overrides
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
        let centerOfSeparator = itemPosition - (separatorWidth / 2.0)
        
        var titleInset = layoutMargins.left
        
        arrowView.center = CGPoint(x: (arrowView.bounds.width / 2.0 + titleInset).rounded(toScale: scale), y: centerOfSeparator.rounded(toScale: scale))
        
        if showsExpandArrow {
            titleInset += 15.0
        }
        
        let titleLabelSize = titleLabel.sizeThatFits(.zero)
        let titleLabelFrame = CGRect(origin: CGPoint(x: titleInset, y: (centerOfSeparator - (titleLabelSize.height / 2.0)).rounded(toScale: scale)), size: titleLabelSize)
        
        titleLabel.frame = titleLabelFrame
        
        let separatorInsetX = titleLabelSize.isEmpty == false ? titleLabelFrame.maxX + 7.0 : titleInset
        
        separatorView.frame = CGRect(x: separatorInsetX, y: itemPosition - separatorWidth, width: bounds.size.width - separatorInsetX, height: separatorWidth)
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }
    
}


// MARK: - Private methods
/// Private methods
fileprivate extension CollectionViewFormMPOLHeaderView {
    
    @objc fileprivate func tapGestureRecognizerDidRecognize() {
        if let indexPath = self.indexPath {
            tapHandler?(self, indexPath)
        }
    }
    
}
