//
//  TableViewFormTextViewCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 10/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext: Int = 1


/// `TableViewFormTextViewCell` implements a UITableViewCell subclass which provides analogous content and
/// behaviour to `CollectionViewFormTextViewCell`, but for use with `UITableView`.
///
/// The `TableViewFormTextViewCell` defines utilizes the textLabel of the Table View cell as the titleLabel,
/// the detailTextLabel as a placeholder for the text, and a `UITextView` instance to allow editing of text.
///
/// Unlike it's Collection-based counterpart, `TableViewFormTextViewCell` self-sizes with AutoLayout. Users
/// do not require to specify a default height, and can allow the cell to indicate it's height dynamically.
/// The cell will also manage editing-on-selection, and ensuring it's container Table View is scrolled to
/// the correct location.
open class TableViewFormTextViewCell: TableViewFormCell {
    
    /// The title label for the cell. This is guaranteed to be non-nil.
    open let titleLabel = UILabel()
    
    
    /// The text view for the cell. You are welcome to become the delegate and/or observe
    /// notifications from the text view in response to editing events.
    open let textView = FormTextView(frame: .zero, textContainer: nil)
    
    
    /// The height constraint guiding autolayout's private sizing of the text view.
    fileprivate var textViewPreferredHeightConstraint: NSLayoutConstraint!
    
    
    /// The height constraint guiding autolayout's minimum sizing of the text view.
    fileprivate var textViewMinimumHeightConstraint: NSLayoutConstraint!
    
    
    /// The constraint separating the title label and text view.
    fileprivate var titleDetailSeparationConstraint: NSLayoutConstraint!
    
    
    /// Initializes the cell with a reuse identifier.
    /// `TableViewFormTextViewCell` does not utilize the `style` parameter.
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    
    /// TableViewFormTextViewCell does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        let titleLabel  = self.titleLabel
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.placeholderLabel.text = "-"
        
        let contentView = self.contentView
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        
        textViewMinimumHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .greaterThanOrEqual, toConstant: textView.font?.lineHeight ?? 17.0 + 1.0)
        textViewPreferredHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toConstant: ceil(textView.font?.lineHeight ?? 17.0 + (textView.font?.leading ?? 1.0)), priority: UILayoutPriorityDefaultLow)
        titleDetailSeparationConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom)
        
        let layoutGuide = contentModeLayoutGuide
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal, toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing),
            
            // lay out the text field with some space for text editing space
            NSLayoutConstraint(item: textView, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading, constant: -5.0),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing, constant: 3.5),
            NSLayoutConstraint(item: textView, attribute: .bottom,   relatedBy: .equal, toItem: layoutGuide, attribute: .bottom, constant: 1.0),
            textViewPreferredHeightConstraint, textViewMinimumHeightConstraint,
            titleDetailSeparationConstraint
        ])
        
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        textView.placeholderLabel.addObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.font),          context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        textView.placeholderLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
}


/// Overriden methods
extension TableViewFormTextViewCell {
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { textView.becomeFirstResponder() }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if object is UITextView || (object as? NSObject == textView.placeholderLabel) {
                if let keyPath = keyPath {
                    switch keyPath {
                    case #keyPath(UITextView.contentSize):
                        updateTextViewPreferredConstraint()
                    case #keyPath(UITextView.contentOffset):
                        if textView.contentOffset.y.isZero == false {
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
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            titleLabel.font     = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            textView.font       = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            textView.placeholderLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            titleLabel.font     = .preferredFont(forTextStyle: .footnote)
            textView.font       = .preferredFont(forTextStyle: .headline)
            textView.placeholderLabel.font = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}

extension TableViewFormTextViewCell {
    
    dynamic open override var accessibilityLabel: String? {
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
    
    dynamic open override var accessibilityValue: String? {
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
    
    dynamic open override var isAccessibilityElement: Bool {
        get {
            if textView.isFirstResponder { return false }
            return super.isAccessibilityElement
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
}


/// Private methods
fileprivate extension TableViewFormTextViewCell {
    
    fileprivate func updateTextViewPreferredConstraint() {
        let textHeight = textView.contentSize.height
        if textViewPreferredHeightConstraint.constant ==~ textHeight { return }
        
        textViewPreferredHeightConstraint.constant = textHeight
        
        guard textView.isFirstResponder,
            let tableView = superview(of: UITableView.self) else {
                layoutIfNeeded()
                return
        }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if let selectedTextRange = textView.selectedTextRange {
            var firstRange = textView.firstRect(for: selectedTextRange)
            if firstRange.origin.y.isInfinite {
                firstRange = CGRect(x: 0.0, y: textView.contentSize.height, width: 0.0, height: 0.0)
            }
            let convertedRect = tableView.convert(firstRange, from: self.textView)
            
            let visibleRect = tableView.bounds.insetBy(tableView.contentInset)
            
            if visibleRect.contains(convertedRect) == false {
                let scale = (window?.screen ?? .main).scale
                if convertedRect.origin.y < visibleRect.origin.y {
                    tableView.contentOffset = CGPoint(x: 0.0, y: (convertedRect.origin.y + tableView.contentInset.top).floored(toScale: scale))
                } else {
                    tableView.contentOffset = CGPoint(x: 0.0, y: (convertedRect.maxY - visibleRect.size.height).floored(toScale: scale))
                }
            }
        }
    }
    
    fileprivate func updateTextViewMinimumConstraint() {
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
    
}
