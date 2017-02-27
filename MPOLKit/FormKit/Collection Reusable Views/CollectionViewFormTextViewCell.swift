//
//  CollectionViewFormTextViewCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 11/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

open class CollectionViewFormTextViewCell: CollectionViewFormCell {
    
    
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
    open class func minimumContentHeight(withTitle title: String?, text: String?, inWidth width: CGFloat, compatibleWidth traitCollection: UITraitCollection, titleFont: UIFont? = nil, textFont: UIFont? = nil) -> CGFloat {
        var height: CGFloat = 0.0
        let screenScale = UIScreen.main.scale
        if let title = title {
            let titleLabelFont = titleFont ?? CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
            
            height += (title as NSString).boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabelFont], context: nil).height.ceiled(toScale: screenScale)
            height += CellTitleDetailSeparation
        }
        
        let textViewFont = textFont ?? CollectionViewFormDetailCell.font(withEmphasis: true, compatibleWith: traitCollection)
        height += max((text as NSString?)?.boundingRect(with: CGSize(width: width - 0.5, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: textViewFont], context: nil).height ?? 0.0, textViewFont.lineHeight).ceiled(toScale: screenScale)
        
        return height
    }
    
    
    /// The title label for the cell.
    open let titleLabel = UILabel(frame: .zero)
    
    /// The text view for the cell.
    open let textView = UITextView(frame: .zero, textContainer: nil)
    
    /// The placeholder label for the cell.
    open let placeholderLabel = UILabel(frame: .zero)
    
    
    /// The selection state of the cell.
    open override var isSelected: Bool {
        didSet { if isSelected && oldValue == false { _ = textView.becomeFirstResponder() } }
    }
    
    
    fileprivate var textViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        let layoutGuide = self.contentModeLayoutGuide
        
        let titleLabel       = self.titleLabel
        let textView         = self.textView
        let placeholderLabel = self.placeholderLabel
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textView.textContainerInset = .zero
        
        placeholderLabel.textColor = .gray
        placeholderLabel.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        
        textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toConstant: textView.contentSize.height, priority: UILayoutPriorityDefaultLow)
        titleDetailSeparationConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            
            // lay out the text field with some space for text editing space
            NSLayoutConstraint(item: textView, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading, constant: -5.0),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing, constant: 3.5),
            NSLayoutConstraint(item: textView, attribute: .bottom,   relatedBy: .equal, toItem: layoutGuide, attribute: .bottom, constant: -1.0),
            textViewHeightConstraint,
            
            // lay out the placeholder so it is visually where the text view "appears" to be
            NSLayoutConstraint(item: placeholderLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            titleDetailSeparationConstraint,
        
            // We should be using baseline, but we can't, so we have a dirty hack:
            NSLayoutConstraint(item: placeholderLabel, attribute: .top, relatedBy: .equal, toItem: textView, attribute: .top, constant: 3.0),
        ])
        
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.text),          context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceholderAppearance), name: .UITextViewTextDidChange, object: textView)
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.text),          context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
}



extension CollectionViewFormTextViewCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if object is UITextView {
                if let keyPath = keyPath {
                    switch keyPath {
                    case #keyPath(UITextView.text):
                        updatePlaceholderAppearance()
                    case #keyPath(UITextView.contentSize):
                        updateTextViewConstraint()
                    case #keyPath(UITextView.contentOffset):
                        // There are a few bugs in UITextView where, during resizing, the content offset gets set to a scrolled position valid
                        // prior to the update, eg a user enters text, which causes resizing and a scroll simultaneously.
                        // We guard against the case, and if any content offset change tries to occur when it's not valid,
                        // we reset back to zero.
                        if textView.contentOffset.y !=~ 0.0 && textView.contentSize.height <= textView.bounds.height {
                            textView.contentOffset.y = 0.0
                        }
                    default:
                        break
                    }
                }
            } else if object is UILabel {
                let titleDetailSpace = titleLabel.text?.isEmpty ?? true ? 0.0 : CellTitleDetailSeparation
                
                if titleDetailSeparationConstraint.constant !=~ titleDetailSpace {
                    titleDetailSeparationConstraint.constant = titleDetailSpace
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        let traitCollection = self.traitCollection
        titleLabel.font = CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        textView.font   = CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        placeholderLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        titleLabel.adjustsFontForContentSizeCategory       = true
        textView.adjustsFontForContentSizeCategory         = true
        placeholderLabel.adjustsFontForContentSizeCategory = true
    }
    
}


// MARK: - Private methods
/// Private methods
fileprivate extension CollectionViewFormTextViewCell {
    
    fileprivate func updateTextViewConstraint() {
        func performUpdate() {
            let textHeight = textView.contentSize.height
            if textViewHeightConstraint.constant !=~ textHeight {
                textViewHeightConstraint.constant = textHeight
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
    
    @objc fileprivate func updatePlaceholderAppearance() {
        placeholderLabel.isHidden = textView.text?.isEmpty ?? true == false
    }
}
