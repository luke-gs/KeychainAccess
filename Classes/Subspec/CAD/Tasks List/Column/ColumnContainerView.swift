//
//  ColumnContainerView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ColumnContainerView: UIView {

    open var dataSource: ColumnContainerViewDataSource?

    open private(set) var columnsInfo: [ColumnInfo] = []
    open private(set) var columnContentViews: [UIView] = []
    open private(set) var columnLeadingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnTrailingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnWidthConstraints: [NSLayoutConstraint] = []
    open private(set) var columnTopBottomConstraints: [NSLayoutConstraint] = []
    
    /// Builds the columns
    open func construct() {
        guard let dataSource = dataSource else { return }
        
        // Clean up old views
        columnContentViews.forEach { $0.removeFromSuperview() }
        columnsInfo.removeAll()
        columnContentViews.removeAll()
        
        for index in 0 ..< dataSource.numberOfColumns(self) {
            columnsInfo.insert(dataSource.columnInfo(self, at: index), at: index)
            columnContentViews.insert(dataSource.viewForColumn(self, at: index), at: index)
            columnContentViews[index].translatesAutoresizingMaskIntoConstraints = false

            addSubview(columnContentViews[index])
        }
        
        layout()
    }
    
    /// Lays out the columns, called by `construct()`
    open func layout() {
        let width = bounds.width
        guard width > 0 else { return }
        
        // Calculate the width
        let calculatedInfo = ColumnInfo.calculateWidths(for: columnsInfo,
                                                        in: width,
                                                        margin: dataSource?.columnSpacing(self) ?? 0)
        
        // Remove all old constraints
        NSLayoutConstraint.deactivate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
        columnLeadingConstraints.removeAll()
        columnTrailingConstraints.removeAll()
        columnWidthConstraints.removeAll()
        columnTopBottomConstraints.removeAll()
        
        // Set up new constraints
        for (index, (info, view)) in zip(calculatedInfo, columnContentViews).enumerated() {
            // Constrain to neighbor view (self if first or last content view)
            let leadingViewAnchor = columnContentViews[ifExists: index - 1]?.trailingAnchor ?? self.leadingAnchor
            let trailingViewAnchor = columnContentViews[ifExists: index + 1]?.leadingAnchor ?? self.trailingAnchor
            
            let leadingMargin = view.leadingAnchor.constraint(equalTo: leadingViewAnchor, constant: info.leadingMargin)
            let trailingMargin = view.trailingAnchor.constraint(lessThanOrEqualTo: trailingViewAnchor, constant: -info.trailingMargin).withPriority(.almostRequired)

            view.translatesAutoresizingMaskIntoConstraints = false

            // Insert new constraints
            columnLeadingConstraints.insert(leadingMargin, at: index)
            columnTrailingConstraints.insert(trailingMargin, at: index)
            columnWidthConstraints.insert(view.widthAnchor.constraint(equalToConstant: info.actualWidth), at: index)
            columnTopBottomConstraints += [
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ]
            
            // Hide the view if its width is 0
            view.isHidden = info.actualWidth == 0
        }
        
        // Activate new constraints
        NSLayoutConstraint.activate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints + columnTopBottomConstraints)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}

public protocol ColumnContainerViewDataSource: class {
    
    /// The number of columns to display in the cell
    func numberOfColumns(_ columnContainerView: ColumnContainerView) -> Int
    
    /// The column info item at the specified index
    func columnInfo(_ columnContainerView: ColumnContainerView, at index: Int) -> ColumnInfo
    
    /// The view to use for the column at the specified index
    func viewForColumn(_ columnContainerView: ColumnContainerView, at index: Int) -> UIView
    
    /// The spacing to use between columns
    func columnSpacing(_ columnContainerView: ColumnContainerView) -> CGFloat
}
