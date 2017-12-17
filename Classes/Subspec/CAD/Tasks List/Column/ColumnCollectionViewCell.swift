//
//  ColumnContainerView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ColumnContainerView: UIView {

    open var dataSource: ColumnCollectionViewCellDataSource?

    open private(set) var columnsInfo: [ColumnInfo] = []
    open private(set) var columnContentViews: [UIView] = []
    open private(set) var columnLeadingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnTrailingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnWidthConstraints: [NSLayoutConstraint] = []
    
    /// Builds the columns
    open func construct() {
        guard let dataSource = dataSource else { return }
        
        columnContentViews.forEach { $0.removeFromSuperview() }
        
        columnsInfo.removeAll()
        columnContentViews.removeAll()
        
        for index in 0 ..< dataSource.numberOfColumns() {
            columnsInfo.insert(dataSource.columnInfo(at: index), at: index)
            columnContentViews.insert(dataSource.viewForColumn(at: index), at: index)
            columnContentViews[index].translatesAutoresizingMaskIntoConstraints = false

            addSubview(columnContentViews[index])
        }
        
        layout()
    }
    
    /// Lays out the columns, called by `construct()`
    open func layout() {
        for columnView in columnContentViews {
            NSLayoutConstraint.activate([
                columnView.topAnchor.constraint(equalTo: self.topAnchor),
                columnView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
    }
    
    
    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            
            // Calculate the width
            let calculatedInfo = ColumnInfo.calculateWidths(for: columnsInfo,
                                                            in: width,
                                                            margin: dataSource?.columnSpacing() ?? 0)

            // Remove all old constraints
            NSLayoutConstraint.deactivate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
            columnLeadingConstraints.removeAll()
            columnTrailingConstraints.removeAll()
            columnWidthConstraints.removeAll()

            // Set up new constraints
            for (index, (info, view)) in zip(calculatedInfo, columnContentViews).enumerated() {
                // Constrain to neighbor view (self if first or last content view)
                let leadingViewAnchor = columnContentViews[ifExists: index - 1]?.trailingAnchor ?? self.leadingAnchor
                let trailingViewAnchor = columnContentViews[ifExists: index + 1]?.leadingAnchor ?? self.trailingAnchor

                let leadingMargin = view.leadingAnchor.constraint(equalTo: leadingViewAnchor, constant: info.leadingMargin)

                let trailingMargin: NSLayoutConstraint
                // If we are the last content view, allow the trailing to be less than the edge and margin
                if info.actualWidth == 0 {
                    trailingMargin = view.trailingAnchor.constraint(lessThanOrEqualTo: trailingViewAnchor)
                } else if index == columnContentViews.count - 1 {
                    trailingMargin = view.trailingAnchor.constraint(lessThanOrEqualTo: trailingViewAnchor, constant: -info.trailingMargin)
                } else {
                    trailingMargin = view.trailingAnchor.constraint(equalTo: trailingViewAnchor, constant: -info.trailingMargin)
                }

                // Add new constraints
                columnLeadingConstraints.insert(leadingMargin, at: index)
                columnTrailingConstraints.insert(trailingMargin, at: index)
                columnWidthConstraints.insert(view.widthAnchor.constraint(equalToConstant: info.actualWidth).withPriority(.almostRequired),
                                              at: index)

                // Hide the view if its with is 0
                view.isHidden = info.actualWidth == 0
            }

            // Activate new constraints
            NSLayoutConstraint.activate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Fix for autolayout getting cooked when view disappears
        NSLayoutConstraint.deactivate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
        NSLayoutConstraint.activate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
    }
}

public protocol ColumnCollectionViewCellDataSource: class {
    
    /// The number of columns to display in the cell
    func numberOfColumns() -> Int
    
    /// The column info item at the specified index
    func columnInfo(at index: Int) -> ColumnInfo
    
    /// The view to use for the column at the specified index
    func viewForColumn(at index: Int) -> UIView
    
    /// The spacing to use between columns
    func columnSpacing() -> CGFloat
}



