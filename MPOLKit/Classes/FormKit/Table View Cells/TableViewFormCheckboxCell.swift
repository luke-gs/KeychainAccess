//
//  TableViewFormCheckboxCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 11/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// The `TableViewFormCheckboxCell` class implements a UITableViewCell subclass which provides
/// analogous content to `CollectionViewFormCheckboxCell`, but for use with `UITableView`.
///
/// Unlike it's Collection-based counterpart, `TableViewFormDetailCell` self-sizes with AutoLayout. Users
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
        isAccessibilityElement = false
        
        selectionStyle = .none
        minimumContentHeight = 43.5
        
        let contentView            = self.contentView
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkbox)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: checkbox, attribute: .leading,   relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: checkbox, attribute: .trailing,  relatedBy: .lessThanOrEqual,    toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: checkbox, attribute: .centerY,   relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: checkbox, attribute: .top,       relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top)
        ])
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        checkbox.titleLabel?.font = SelectableButton.font(compatibleWith: traitCollection)
    }
    
}
