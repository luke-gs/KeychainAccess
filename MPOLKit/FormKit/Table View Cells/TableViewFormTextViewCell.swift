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
    
    
    /// The text view for the cell. Users are welcome to become the delegate and/or observe
    /// notifications from the text view in response to editing events
    open let textView: UITextView
    
    
    /// The placeholder label for the cell.
    open var placeholderLabel = UILabel()
    
    
    /// The height constraint guiding autolayout's sizing of the text view,
    /// and thus the cell. This is private and not accessible to users.
    fileprivate let textViewHeightConstraint: NSLayoutConstraint
    
    
    /// Initializes the cell with a reuse identifier.
    /// `TableViewFormTextViewCell` does not utilize the `style` parameter.
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 2.0, left: -4.0, bottom: 2.0, right: -3.5)
        textView.backgroundColor    = nil
        self.textView = textView
        
        textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toConstant: textView.contentSize.height, priority: UILayoutPriorityRequired - 1)
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let titleLabel  = self.titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholderLabel = self.placeholderLabel
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "-"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .gray
        
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentSize),   context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.text),          context: &kvoContext)
        textView.addObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
        
        let layoutGuide = UILayoutGuide()
        
        let contentView = self.contentView
        contentView.addLayoutGuide(layoutGuide)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceholderAppearance), name: .UITextViewTextDidChange, object: textView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,              toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,              toItem: layoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: layoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: placeholderLabel, attribute: .leading,  relatedBy: .equal,           toItem: textView, attribute: .leading),
            NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textView, attribute: .trailing),
            NSLayoutConstraint(item: placeholderLabel, attribute: .top,      relatedBy: .equal,           toItem: textView, attribute: .top, constant: 2.5),
            NSLayoutConstraint(item: placeholderLabel, attribute: .bottom,   relatedBy: .lessThanOrEqual, toItem: textView, attribute: .bottom),
            
            NSLayoutConstraint(item: textView, attribute: .top,      relatedBy: .equal, toItem: titleLabel,  attribute: .bottom),
            NSLayoutConstraint(item: textView, attribute: .bottom,   relatedBy: .equal, toItem: layoutGuide, attribute: .bottom),
            NSLayoutConstraint(item: textView, attribute: .leading,  relatedBy: .equal, toItem: layoutGuide, attribute: .leading),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: layoutGuide, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins),
            NSLayoutConstraint(item: layoutGuide, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerXWithinMargins),
            NSLayoutConstraint(item: layoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: layoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin),
            
            NSLayoutConstraint(item: textView,  attribute: .height,   relatedBy: .greaterThanOrEqual, toConstant: 18.0),
            textViewHeightConstraint
        ])
    }
    
    /// TableViewFormTextViewCell does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("TableViewFormTextViewCell does not support NSCoding.")
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.text),        context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize), context: &kvoContext)
        textView.removeObserver(self, forKeyPath: #keyPath(UITextView.contentOffset), context: &kvoContext)
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
            if let keyPath = keyPath {
                switch keyPath {
                case #keyPath(UITextView.text):
                    updatePlaceholderAppearance()
                case #keyPath(UITextView.contentSize):
                    updateTextViewConstraint()
                case #keyPath(UITextView.contentOffset):
                    if textView.contentOffset.y.isZero == false {
                        textView.contentOffset.y = 0.0
                    }
                default:
                    break
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        titleLabel.font = CollectionViewFormDetailCell.font(withEmphasis: false, compatibleWith: traitCollection)
        textView.font   = CollectionViewFormDetailCell.font(withEmphasis: true,  compatibleWith: traitCollection)
        placeholderLabel.font = textView.font
        
        titleLabel.adjustsFontForContentSizeCategory       = true
        textView.adjustsFontForContentSizeCategory         = true
        placeholderLabel.adjustsFontForContentSizeCategory = true
    }
}


/// Private methods
fileprivate extension TableViewFormTextViewCell {
    
    fileprivate func updateTextViewConstraint() {
        let textHeight = textView.contentSize.height
        if abs(textViewHeightConstraint.constant - textHeight) < 0.1 { return }
        
        textViewHeightConstraint.constant = textHeight
        
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
    
    @objc fileprivate func updatePlaceholderAppearance() {
        placeholderLabel.isHidden = textView.text?.isEmpty ?? true == false
    }
}
