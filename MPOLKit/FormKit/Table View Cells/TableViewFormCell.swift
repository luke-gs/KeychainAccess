//
//  TableViewFormCell.swift
//  VCom
//
//  Created by Rod Brown on 18/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// `TableViewFormCell` implements a UITableViewCell which allows for additional minimum sizing
/// constraints to provide an appearance similar to that provided by FormKit's Collection-based
/// classes.
///
/// Unlike it's Collection-based counterpart, `TableViewFormCell` self-sizes with AutoLayout. Users do not
/// need to use delegate methods to specify minimum height details, and can instead allow AutoLayout, and
/// the mimumumContentHeight value, to indicate the size of the cell dynamically.
open class TableViewFormCell: UITableViewCell {
    
    /// The minimum content height for the cell.
    /// This value is analogous to providing a minimum height to CollectionViewDelegateFormLayout,
    /// and indicates how high the content within the layout margins of the cell should be.
    open var minimumContentHeight: CGFloat {
        get { return minimumHeightConstraint.constant }
        set { minimumHeightConstraint.constant = newValue }
    }
    
    /// The height constraint responsible for managing the minimum height of the cell.
    private var minimumHeightConstraint: NSLayoutConstraint!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        minimumHeightConstraint = NSLayoutConstraint(item: contentView, attribute: .bottomMargin, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin, constant: 44.0 - UIScreen.main.singlePixelSize, priority: UILayoutPriorityDefaultHigh)
        minimumHeightConstraint.isActive = true
    }
}
