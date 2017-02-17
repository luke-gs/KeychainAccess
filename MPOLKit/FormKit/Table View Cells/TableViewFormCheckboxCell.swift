//
//  TableViewFormCheckboxCell.swift
//  VCom
//
//  Created by Rod Brown on 11/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// The `TableViewFormCheckboxCell` class implements a UITableViewCell subclass which provides
/// analogous content to `CollectionViewFormCheckboxCell`, but for use with `UITableView`.
///
/// Unlike it's Collection-based counterpart, `TableViewFormSubtitleCell` self-sizes with AutoLayout. Users
/// do not require to specify a default height, and can allow the cell to indicate it's height dynamically.
///
/// Additionally, unlike it's Collection-based counterpart, this class does not tie it's selection to the
/// cell's selection state. This is due to the fact users might like use a checkmark cell on a table view
/// that supports editing, and enabling multiple selection during editing causes the standard table
/// multi-select editing picker, which would not be desirable.
open class TableViewFormCheckboxCell: TableViewFormCell {
    
    /// The checkbox for the cell.
    open let checkbox = CheckBox(frame: .zero)
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        minimumContentHeight = 43.5
        
        let contentView = self.contentView
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkbox)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: checkbox, attribute: .leading,   relatedBy: .equal,              toItem: contentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: checkbox, attribute: .trailing,  relatedBy: .lessThanOrEqual,    toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: checkbox, attribute: .centerY,   relatedBy: .equal,              toItem: contentView, attribute: .centerYWithinMargins),
            NSLayoutConstraint(item: checkbox, attribute: .top,       relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin)
        ])
    }
    
}
