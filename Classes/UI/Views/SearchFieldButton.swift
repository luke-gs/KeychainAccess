//
//  SearchFieldButton.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A bar for displaying a search button that appears like a search field.
open class SearchFieldButton: UIButton {
    
    /// The text for the field. The default is `nil`.
    open var text: String? {
        didSet {
            if text != oldValue {
                updateTextAndColor()
            }
        }
    }
    
    /// The text color for the text when not displaying a placeholder. The
    /// default is `UIColor.darkText`.
    open var textColor: UIColor? = UIColor.darkText {
        didSet {
            if text?.isEmpty ?? true == false && textColor != oldValue {
                updateTextAndColor()
            }
        }
    }
    
    /// The placeholder string. The default is "Search", localized for the
    /// current locale.
    open var placeholder: String? = NSLocalizedString("Search", bundle: Bundle(for: SearchFieldButton.self), comment: "Default search placeholder") {
        didSet {
            if text?.isEmpty ?? true && placeholder != oldValue {
                updateTextAndColor()
            }
        }
    }
    
    /// The text color for the placeholder. The default is `UIColor.gray`.
    open var placeholderTextColor: UIColor? = UIColor.gray {
        didSet {
            if text?.isEmpty ?? true && placeholderTextColor != oldValue {
                updateTextAndColor()
            }
        }
    }
    
    /// The background color for the field. The default is `white`.
    open var fieldColor: UIColor! = .white {
        didSet {
            if fieldColor == nil {
                fieldColor = .white
            }
            
            if fieldColor != oldValue {
                updateFieldImage()
            }
        }
    }
    
    /// An accessory view to show trailing the content, in the field.
    open var accessoryView: UIView? {
        didSet {
            if oldValue != accessoryView {
                if let oldValue = oldValue,
                    oldValue.superview == self {
                    oldValue.removeFromSuperview()
                }
                
                if let accessoryView = self.accessoryView {
                    addSubview(accessoryView)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    
    private var accessorySize: CGSize = .zero

    
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
        backgroundColor = #colorLiteral(red: 0.9133402705, green: 0.9214604497, blue: 0.9297196269, alpha: 1)
        updateFieldImage()
        
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
        contentVerticalAlignment = .center
        
        if let titleLabel = self.titleLabel {
            titleLabel.font = .systemFont(ofSize: 15.0, weight: UIFontWeightRegular)
            titleLabel.textAlignment = .natural
        }
        
        setImage(UIImage(named: "iconSystemSearchField", in: .mpolKit, compatibleWith: nil), for: .normal)
        
        updateTextAndColor()
        
        // TODO: iOS 11 - transition to .leading
        updateHorizontalAlignment()
    }
    
    
    // MARK: - Overrides
    
    open override var intrinsicContentSize: CGSize {
        var intrinsicSize = super.intrinsicContentSize
        let minimumHeight: CGFloat = traitCollection.horizontalSizeClass == .compact ? 44.0 : 64.0
        if intrinsicSize.height < minimumHeight {
            intrinsicSize.height = minimumHeight
        }
        return intrinsicSize
    }
    
    open override func layoutSubviews() {
        let bounds = self.bounds

        super.layoutSubviews()
        
        guard let accessoryView = self.accessoryView else { return }
        let contentRect = self.contentRect(forBounds: bounds)

        accessorySize = accessoryView.frame.size

        let accessoryFrame = CGRect(origin: CGPoint(x: contentRect.maxX - accessorySize.width,
                                                    y: (contentRect.midY - (accessorySize.height / 2.0)).rounded(toScale: traitCollection.currentDisplayScale)),
                                    size: accessorySize)
        
        accessoryView.frame = accessoryFrame
    }
    
    /// Adjusting the background image on this button is not supported.
    ///
    /// You can either adjust the `backgroundColor` to adjust the bar color,
    /// or the `fieldColor` to adjust the field's color.
    open override func setBackgroundImage(_ image: UIImage?, for state: UIControlState) {
        // No op.
    }
    
    open override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        let xInset: CGFloat = traitCollection.horizontalSizeClass == .compact ? 8.0 : 16.0
        
        var backgroundRect: CGRect = bounds.insetBy(dx: xInset, dy: 16.0)
        if backgroundRect.height < 32.0 {
            backgroundRect.size.height = 32.0
            backgroundRect.origin.y = max(((bounds.height - 32.0) / 2.0).rounded(toScale: traitCollection.currentDisplayScale), 0.0)
        }
        
        if backgroundRect.width < 32.0 {
            backgroundRect.size.width = 32.0
        }
        
        return backgroundRect
    }
    
    open override func contentRect(forBounds bounds: CGRect) -> CGRect {
        var rect = self.backgroundRect(forBounds: bounds)
        
        let leadingInset: CGFloat = traitCollection.horizontalSizeClass == .compact ? 9.0 : 18.0
        
        rect.size.width = max(rect.width - leadingInset - 8.0, 0.0)
        
        if effectiveUserInterfaceLayoutDirection == .leftToRight {
            rect.origin.x += leadingInset
        }
        
        return rect
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHorizontalAlignment()
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet { updateHorizontalAlignment() }
    }


    public func update(for searchable: Searchable) {
        self.text = searchable.text
    }
    
    // MARK: - Private methods

    private func updateFieldImage() {
        func setFieldColor(_ color: UIColor, for state: UIControlState) {
            super.setBackgroundImage(.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: color), for: state)
        }
        
        setFieldColor(fieldColor, for: .normal)
        setFieldColor(fieldColor.adjustingBrightness(byFactor: 0.8), for: .highlighted)
    }
    
    private func updateTextAndColor() {
        if let text = self.text?.ifNotEmpty() {
            setTitle(text, for: .normal)
            setTitleColor(textColor, for: .normal)
        } else {
            setTitle(placeholder, for: .normal)
            setTitleColor(placeholderTextColor, for: .normal)
        }
    }
    
    @available(*, deprecated: 11, message: "Use contentHorizontalAlignment = .leading.")
    private func updateHorizontalAlignment() {
        contentHorizontalAlignment = effectiveUserInterfaceLayoutDirection == .leftToRight ? .left : .right
    }
    
}
