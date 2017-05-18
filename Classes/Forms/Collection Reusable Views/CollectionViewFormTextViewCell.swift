//
//  CollectionViewFormTextViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

open class CollectionViewFormTextViewCell: CollectionViewFormCell {
    
    
    // MARK: - Public properties
    
    /// The title label for the cell.
    open let titleLabel = UILabel(frame: .zero)
    
    /// The text view for the cell.
    open let textView = FormTextView(frame: .zero, textContainer: nil)
    
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false && textView.isEditable { _ = textView.becomeFirstResponder() } }
    }
    
    
    // MARK: - Private properties
    
    private var textViewMinimumHeightConstraint: NSLayoutConstraint!
    
    private var textViewPreferredHeightConstraint: NSLayoutConstraint!
    
    private var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    
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
        selectionStyle = .underline
        
        let contentView = self.contentView
        let layoutGuide = self.contentModeLayoutGuide
        
        let titleLabel       = self.titleLabel
        let textView         = self.textView
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 10, *) {
            titleLabel.adjustsFontForContentSizeCategory = true
            textView.adjustsFontForContentSizeCategory = true
            textView.placeholderLabel.adjustsFontForContentSizeCategory = true
        }
        
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        textView.font   = .preferredFont(forTextStyle: .headline)
        textView.placeholderLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        
        textViewMinimumHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .greaterThanOrEqual, toConstant: ceil(textView.font?.lineHeight ?? 17.0) + (textView.font?.leading ?? 1.0))
        
        textViewPreferredHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toConstant: textView.contentSize.height, priority: UILayoutPriorityDefaultLow)
        titleDetailSeparationConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal,           toItem: layoutGuide, attribute: .trailing, priority: UILayoutPriorityDefaultLow),
            
            // lay out the text field with some space for text editing space
            NSLayoutConstraint(item: textView, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading,  constant: -5.0),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing, constant: 3.5),
            NSLayoutConstraint(item: textView, attribute: .bottom,   relatedBy: .equal, toItem: layoutGuide, attribute: .bottom,   constant: 1.0),
            
            textViewPreferredHeightConstraint, textViewMinimumHeightConstraint,
            titleDetailSeparationConstraint
        ])
        
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        textView.placeholderLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing(_:)), name: .UITextViewTextDidBeginEditing, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidEndEditing(_:)),   name: .UITextViewTextDidEndEditing,   object: textView)
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        textView.placeholderLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            if width !=~ oldValue.width {
                titleLabel.preferredMaxLayoutWidth    = width
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            let width = frame.width
            if width !=~ oldValue.width {
                titleLabel.preferredMaxLayoutWidth    = width
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if object is UITextView || (object as? NSObject == textView.placeholderLabel) {
                if let keyPath = keyPath {
                    switch keyPath {
                    case #keyPath(UITextView.contentSize):
                        updateTextViewPreferredConstraint()
                    case #keyPath(UITextView.contentOffset):
                        // There are a few bugs in UITextView where, during resizing, the content offset gets set to a scrolled position valid
                        // prior to the update, eg a user enters text, which causes resizing and a scroll simultaneously.
                        // We guard against the case, and if any content offset change tries to occur when it's not valid,
                        // we reset back to zero.
                        if textView.contentOffset.y !=~ 0.0 && textView.contentSize.height <=~ textView.bounds.height {
                            textView.contentOffset.y = 0.0
                        }
                    case #keyPath(UITextView.font), #keyPath(UILabel.font):
                        updateTextViewMinimumConstraint()
                    default:
                        break
                    }
                }
            } else if object is UILabel {
                // We take 0.5 from the standard separation to deal with inconsistencies with how UITextView lays out text vs UILabel.
                // This does not affect the sizing method.
                let titleDetailSpace = titleLabel.text?.isEmpty ?? true ? 0.0 : CellTitleSubtitleSeparation - 0.5
                
                if titleDetailSeparationConstraint.constant !=~ titleDetailSpace {
                    titleDetailSeparationConstraint.constant = titleDetailSpace
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
        super.contentSizeCategoryDidChange(newCategory)
        
        if #available(iOS 10, *) { return }
        
        titleLabel.legacy_adjustFontForContentSizeCategoryChange()
        textView.legacy_adjustFontForContentSizeCategoryChange()
        textView.placeholderLabel.legacy_adjustFontForContentSizeCategoryChange()
    }
    
    
    // MARK: - Accessibility

    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return titleLabel.text
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    open override var accessibilityValue: String? {
        get {
            if let setValue = super.accessibilityValue {
                return setValue
            }
            let text = textView.text
            if text?.isEmpty ?? true {
                return textView.placeholderLabel.text
            }
            return text
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    open override var isAccessibilityElement: Bool {
        get {
            if textView.isFirstResponder { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateTextViewPreferredConstraint() {
        func performUpdate() {
            let textHeight = textView.contentSize.height
            if textViewPreferredHeightConstraint.constant !=~ textHeight {
                textViewPreferredHeightConstraint.constant = textHeight
            }
        }
        
        if UIView.inheritedAnimationDuration > 0.0 {
            // We need to delay this update for a slight amount. This works around a bug where updating during some animations
            // where the animation will cause content size changes, causes auto-layout to break if we make the change during the animation.
            // This will occur on rotation events, for example. `UIView.performWithoutAnimation(_:)` does not fix this bug.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: performUpdate)
        } else {
            performUpdate()
        }
    }
    
    private func updateTextViewMinimumConstraint() {
        let textViewFont: UIFont
        let placeholderFont: UIFont
        
        if #available(iOS 10, *) {
            textViewFont        = textView.font ?? .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
            placeholderFont     = textView.placeholderLabel.font ?? .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            textViewFont        = textView.font ?? .preferredFont(forTextStyle: .headline)
            placeholderFont     = textView.placeholderLabel.font ?? .preferredFont(forTextStyle: .subheadline)
        }
        
        textViewMinimumHeightConstraint?.constant = ceil(max(textViewFont.lineHeight + textViewFont.leading, placeholderFont.lineHeight + placeholderFont.leading))
    }
    
    @objc private func textViewDidBeginEditing(_ notification: NSNotification) {
        guard isSelected == false,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    @objc private func textViewDidEndEditing(_ notification: NSNotification) {
        guard isSelected,
            let collectionView = superview(of: UICollectionView.self),
            let indexPath = collectionView.indexPath(for: self) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for an instance of CollectionViewFormTextViewCell.
    /// You should use this method instead of creating a separate reference cell.
    ///
    /// - Parameters:
    ///   - title:      The title text for the cell.
    ///   - text:       The content text for the text view.
    ///   - width:      The content width for the cell.
    ///   - traitCollection: The trait collection context the cell will be presented in. This may affect the standard fonts.
    ///   - titleFont:  The title font of the cell. The default is `nil`, specifying the standard title font.
    ///   - textFont:   The content font for the text view. the default is `nil`, specifying the standard content font.
    /// - Returns:      The minimum appropriate height for the cell.
    open class func minimumContentHeight(withTitle title: String?, enteredText: String?, placeholder: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection, titleFont: UIFont? = nil, textViewFont: UIFont? = nil, placeholderFont: UIFont? = nil) -> CGFloat {
        var height: CGFloat = 0.0
        let screenScale = UIScreen.main.scale
        if let title = title {
            let titleTextFont: UIFont
            if #available(iOS 10, *) {
                titleTextFont = titleFont ?? .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            } else {
                titleTextFont = titleFont ?? .preferredFont(forTextStyle: .footnote)
            }
            
            height += (title as NSString).boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleTextFont], context: nil).height.ceiled(toScale: screenScale)
            height += CellTitleSubtitleSeparation
        }
        
        let textFont: UIFont
        if #available(iOS 10, *) {
            textFont = textViewFont ?? .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        } else {
            textFont = textViewFont ?? .preferredFont(forTextStyle: .headline)
        }
        
        height += max((enteredText as NSString?)?.boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil).height ?? 0.0, textFont.lineHeight).ceiled(toScale: screenScale)
        return height
    }
    
}
