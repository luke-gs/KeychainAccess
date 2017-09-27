//
//  TableViewFormCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 18/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// `TableViewFormCell` implements a UITableViewCell which allows for additional minimum sizing
/// constraints to provide an appearance similar to that provided by MPOlKit's Collection-based
/// form classes.
///
/// Unlike it's Collection-based counterpart, `TableViewFormCell` self-sizes with AutoLayout. Users do not
/// need to use delegate methods to specify minimum height details, and can instead allow AutoLayout, and
/// the mimumumContentHeight value, to indicate the size of the cell dynamically.
open class TableViewFormCell: UITableViewCell, DefaultReusable {
    
    /// The minimum content height for the cell.
    /// This value is analogous to providing a minimum height to CollectionViewDelegateFormLayout,
    /// and indicates how high the content within the layout margins of the cell should be.
    open var minimumContentHeight: CGFloat {
        get { return minimumHeightConstraint.constant }
        set { minimumHeightConstraint.constant = newValue }
    }
    
    
    /// This layout guide is applied to the cell's contentView, and positions content in the
    /// correct vertical position for the current `contentMode`. This layout guide is constrainted
    /// to the layout margins for the content view.
    ///
    /// Subclasses should position their content with this layout guide, rather than the content
    /// view's layout margins.
    open let contentModeLayoutGuide: UILayoutGuide = UILayoutGuide()
    
    
    // MARK: - Private properties
    
    /// The content mode guide. This guide is private and will update to enforce the current content
    /// mode on the `contentModeLayoutGuide`.
    private var contentModeLayoutConstraint: NSLayoutConstraint!
    
    
    /// The height constraint responsible for managing the minimum height of the cell.
    private var minimumHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Initializers
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit() {
        let contentView = self.contentView
        
        contentView.addLayoutGuide(contentModeLayoutGuide)
        
        /// A minimum content height of 23.0 is the standard for a table view cell.
        minimumHeightConstraint = NSLayoutConstraint(item: contentView, attribute: .bottomMargin, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin, constant: 23.0, priority: UILayoutPriority.defaultHigh)
        
        contentModeLayoutConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins, priority: UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.defaultLow.rawValue) - 1)))
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .top,      relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .bottom,   relatedBy: .lessThanOrEqual,    toItem: contentView, attribute: .bottomMargin, priority: UILayoutPriority(rawValue: 500)),
            contentModeLayoutConstraint, minimumHeightConstraint
        ])
    }
    
}
