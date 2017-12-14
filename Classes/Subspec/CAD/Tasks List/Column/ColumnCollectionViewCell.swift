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

    open func construct() {
        guard let dataSource = dataSource else { return }
        
        columnsInfo.removeAll()
        columnContentViews.removeAll()
        
        for index in 0 ..< dataSource.numberOfColumns() {
            columnsInfo[index] = dataSource.columnInfo(at: index)
            columnContentViews[index] = dataSource.viewForColumn(at: index)
        }
    }
    
    open func layout() {
        var constraints: [NSLayoutConstraint] = []
        
        for (index, (columnInfo, columnView)) in zip(columnsInfo, columnContentViews).enumerated() {
            let leadingViewAnchor = columnContentViews[ifExists: index - 1]?.trailingAnchor ?? self.leadingAnchor
            let trailingViewAnchor = columnContentViews[ifExists: index + 1]?.leadingAnchor ?? self.trailingAnchor
            
            NSLayoutConstraint.activate([
                columnView.topAnchor.constraint(equalTo: self.topAnchor),
                columnView.leadingAnchor.constraint(equalTo: leadingViewAnchor, constant: columnInfo.leadingMargin),
                columnView.trailingAnchor.constraint(equalTo: trailingViewAnchor, constant: columnInfo.leadingMargin),
                columnView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//                columnView.trailingAnchor.constraint(equalTo: trailingView., constant: -columnInfo.trailingMargin)
            ])
        }
    }
}

public protocol ColumnCollectionViewCellDataSource: class {
    func numberOfColumns() -> Int
    func columnInfo(at index: Int) -> ColumnInfo
    func viewForColumn(at index: Int) -> UIView
}



