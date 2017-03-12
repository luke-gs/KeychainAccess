//
//  TableViewFormDetailCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 10/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1


/// The `TableViewFormDetailCell` class implements a UITableViewCell subclass which provides
/// analogous content and behaviour to `CollectionViewFormDetailCell`, but for use with `UITableView`.
///
/// `TableViewFormDetailCell` adds to the behaviour of `UITableViewCellStyle.Subtitle` by providing support
/// for mutli-line labels in both the title and detail label. This can be important in implementing support
/// for content that must wrap and show in the detail, which the default cell does not support. Additionally
/// the class configures the labels with the appropriate fonts to replicate the appearance of
/// `CollectionViewFormDetailCell`.
///
/// Unlike it's Collection-based counterpart, `TableViewFormDetailCell` self-sizes with AutoLayout. Users
/// do not require to specify a default height, and can allow the cell to indicate it's height dynamically.
open class TableViewFormDetailCell: TableViewFormCell {
    
    /// The text label for the cell. This is guaranteed to be non-nil.
    open override var textLabel: UILabel {
        return super.textLabel!
    }
    
    /// The detail text label for the cell. This is guaranteed to be non-nil.
    open override var detailTextLabel: UILabel {
        return super.detailTextLabel!
    }
    
    /// The font emphasis for the cell. The default is `.title`.
    open var emphasis: CollectionViewFormDetailCell.Emphasis = .title {
        didSet { applyStandardFonts() }
    }
    
    
    /// The current label vertical constraints. This is private and not accessible to users.
    fileprivate var labelConstraints: [NSLayoutConstraint]?
    
    
    /// The label state for the cell.
    /// This is a helper tracker internally to help limit the occasions where updating label text will
    /// cause a constraint update.
    fileprivate var labelState: LabelState = .none
    
    
    /// Initializes the cell with a reuse identifier.
    /// TableViewFormDetailCell does not utilize the `style` parameter, instead always using `Subtitle`.
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let textLabel       = self.textLabel
        let detailLabel     = self.detailTextLabel
        
        textLabel.translatesAutoresizingMaskIntoConstraints   = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.addObserver(self,   forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        textLabel.addObserver(self,   forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
        detailLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        detailLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    /// TableViewFormDetailCell does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("TableViewFormDetailCell does not support NSCoding.")
    }
    
    deinit {
        let textLabel   = self.textLabel
        let detailLabel = self.detailTextLabel
        
        textLabel.removeObserver(self,   forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        textLabel.removeObserver(self,   forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
        detailLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text),           context: &kvoContext)
        detailLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
}


/// Overriden methods
extension TableViewFormDetailCell {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            updateLabelState()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func updateConstraints() {
        let labelState = self.labelState
        if labelConstraints?.isEmpty ?? true && labelState != .none {
            let layoutGuide = self.contentModeLayoutGuide
            
            let textLabel   = self.textLabel
            let detailLabel = self.detailTextLabel
            
            var newConstraints: [NSLayoutConstraint] = []
            if labelState != .detailOnly {
                newConstraints = [
                    NSLayoutConstraint(item: textLabel, attribute: .top,      relatedBy: .equal,           toItem: layoutGuide, attribute: .top),
                    NSLayoutConstraint(item: textLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
                    NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing)
                ]
            }
            
            if labelState != .titleOnly {
                newConstraints += [
                    NSLayoutConstraint(item: detailLabel, attribute: .bottom,   relatedBy: .equal,           toItem: layoutGuide, attribute: .bottom),
                    NSLayoutConstraint(item: detailLabel, attribute: .leading,  relatedBy: .equal,           toItem: layoutGuide, attribute: .leading),
                    NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: layoutGuide, attribute: .trailing)
                ]
            }
            
            switch labelState {
            case .titleAndDetail:
                // Constrain the detail label's top to be slightly below the text label's bottom.
                newConstraints.append(NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: textLabel, attribute: .bottom, constant: CellTitleDetailSeparation))
            case .titleOnly:
                // Constrain the text label's bottom to be the labelLayoutGuide's bottom.
                // The detail label will have no height at our label's bottom.
                newConstraints.append(NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: layoutGuide, attribute: .bottom))
            case .detailOnly:
                // Constrain the detail label's top to be the labelLayoutGuide's top.
                // The detail label will have no height at our label's bottom.
                newConstraints.append(NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: layoutGuide, attribute: .top))
            case .none:
                // This case will never be reached, we only follow this code path if it is not "none"
                break
            }
            
            if newConstraints.isEmpty == false {
                NSLayoutConstraint.activate(newConstraints)
                self.labelConstraints = newConstraints
            }
        }
        
        super.updateConstraints()
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        let traitCollection = self.traitCollection
        textLabel.font       = CollectionViewFormDetailCell.font(withEmphasis: emphasis == .title,  compatibleWith: traitCollection)
        detailTextLabel.font = CollectionViewFormDetailCell.font(withEmphasis: emphasis == .detail, compatibleWith: traitCollection)
        
        textLabel.adjustsFontForContentSizeCategory       = true
        detailTextLabel.adjustsFontForContentSizeCategory = true
    }
    
}


fileprivate extension TableViewFormDetailCell {
    
    /// A helper enum to help track the current state of the labels.
    enum LabelState {
        case none, titleOnly, detailOnly, titleAndDetail
    }
    
    /// Updates the label state, and invalidates constraints if necessary.
    /// This is a workaround purely for performance: On scroll, if text changes but doesn't
    /// get removed, we can avoid changing constraints on the fly.
    /// This method should be called every time label text changes.
    fileprivate func updateLabelState() {
        let hasText   = textLabel.text?.isEmpty       ?? true == false
        let hasDetail = detailTextLabel.text?.isEmpty ?? true == false
        
        let newState: LabelState
        if hasText {
            newState = hasDetail ? .titleAndDetail : .titleOnly
        } else if hasDetail {
            newState = .detailOnly
        } else {
            newState = .none
        }
        
        if newState != labelState {
            if let labelConstraints = self.labelConstraints {
                NSLayoutConstraint.deactivate(labelConstraints)
                self.labelConstraints = nil
            }
            self.labelState = newState
            setNeedsUpdateConstraints()
        }
    }
    
}

