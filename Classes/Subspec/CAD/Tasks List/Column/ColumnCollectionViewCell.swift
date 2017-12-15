//
//  ColumnCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 14/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ColumnCollectionViewCell: CollectionViewFormCell {

    open weak var dataSource: ColumnCollectionViewCellDataSource?

    open private(set) var columnsInfo: [ColumnInfo] = []
    open private(set) var columnContentViews: [UIView] = []
    open private(set) var columnLeadingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnTrailingConstraints: [NSLayoutConstraint] = []
    open private(set) var columnWidthConstraints: [NSLayoutConstraint] = []
    
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
    
    open func layout() {
        NSLayoutConstraint.deactivate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
        columnLeadingConstraints.removeAll()
        columnTrailingConstraints.removeAll()
        columnWidthConstraints.removeAll()
        for (index, (columnInfo, columnView)) in zip(columnsInfo, columnContentViews).enumerated() {
            
            let leadingViewAnchor = columnContentViews[ifExists: index - 1]?.trailingAnchor ?? self.layoutMarginsGuide.leadingAnchor
            let trailingViewAnchor = columnContentViews[ifExists: index + 1]?.leadingAnchor ?? self.layoutMarginsGuide.trailingAnchor
            
            let leadingMargin = columnView.leadingAnchor.constraint(lessThanOrEqualTo: leadingViewAnchor, constant: columnInfo.leadingMargin)
                .withPriority(.required)
            
            let trailingMargin = columnView.trailingAnchor.constraint(lessThanOrEqualTo: trailingViewAnchor, constant: -columnInfo.trailingMargin)
                .withPriority(.required)
            
            columnLeadingConstraints.insert(leadingMargin, at: index)
            columnTrailingConstraints.insert(trailingMargin, at: index)
            columnWidthConstraints.insert(columnView.widthAnchor.constraint(equalToConstant: columnInfo.actualWidth).withPriority(.required), at: index)

            NSLayoutConstraint.activate([
                columnView.topAnchor.constraint(equalTo: self.topAnchor),
                columnView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                columnLeadingConstraints[index],
                columnTrailingConstraints[index],
                columnWidthConstraints[index],
            ])
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            print("Bounds: \(bounds.size.width)")
            
            let width = bounds.width - layoutMargins.left - layoutMargins.right - (dataSource?.widthOffset() ?? 0)
            let calculatedInfo = ColumnInfo.calculateWidths(for: columnsInfo,
                                                            in: width,
                                                            margin: dataSource?.columnSpacing() ?? 0)
            
            NSLayoutConstraint.deactivate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)

            for (index, (info, view)) in zip(calculatedInfo, columnContentViews).enumerated() {
                columnLeadingConstraints[index].constant = info.leadingMargin
                columnTrailingConstraints[index].constant = -info.trailingMargin
                columnWidthConstraints[index].constant = info.actualWidth
                
                print("Column at index \(index):")
                print("Leading: \(info.leadingMargin)")
                print("Trailing: \(info.trailingMargin)")
                print("Width: \(info.actualWidth)")
                print()
                
                view.isHidden = info.actualWidth == 0
            }
            
            NSLayoutConstraint.activate(columnLeadingConstraints + columnTrailingConstraints + columnWidthConstraints)
            
            
            setNeedsLayout()
            layoutIfNeeded()
        }
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
    
    /// Any additional width to subtract from the width (e.g. accessory view width)
    func widthOffset() -> CGFloat
}



