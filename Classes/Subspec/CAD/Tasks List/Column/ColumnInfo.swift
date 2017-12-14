//
//  ColumnInfo.swift
//  MPOLKit
//
//  Created by Kyle May on 13/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//`

import UIKit

public struct ColumnInfo: Equatable {

    /// `ColumnInfo` initialized with zero width
    public static let zero = ColumnInfo(minimumWidth: 0, maximumWidth: 0)
    
    /// Minimum width of the column
    public var minimumWidth: CGFloat
    
    /// Maxmimum width of the column
    public var maximumWidth: CGFloat
    
    /// Margin for the leading
    public private(set) var leadingMargin: CGFloat = 0
    
    /// Margin for the trailing
    public private(set) var trailingMargin: CGFloat = 0

    /// Actual calculated width of the column
    public private(set) var actualWidth: CGFloat = 0
    
    public init(minimumWidth: CGFloat, maximumWidth: CGFloat) {
        assert(minimumWidth <= maximumWidth, "Minimum width cannot be greater than the maximum width")
        
        self.minimumWidth = minimumWidth
        self.maximumWidth = maximumWidth
    }
    
    public init(width: CGFloat) {
        self.minimumWidth = width
        self.maximumWidth = width
    }
    
    public static func ==(lhs: ColumnInfo, rhs: ColumnInfo) -> Bool {
        return (lhs.minimumWidth == rhs.minimumWidth) && (lhs.maximumWidth == rhs.maximumWidth)
    }
    
    /// Calculates the widths for columns in a specified width
    public static func calculateWidths(for columns: [ColumnInfo], in width: CGFloat, margin: CGFloat = 0) -> [ColumnInfo] {
        var totalMinWidth: CGFloat = 0
        var visibleColumns: [ColumnInfo] = []
        
        // Calculate the total min width and the visible columns
        for column in columns {
            // If the the existing min cell widths plus current cell width will fit in our total width
            if totalMinWidth + column.minimumWidth <= width {
                totalMinWidth += column.minimumWidth
                visibleColumns.append(column)
            } else {
                break
            }
        }
        
        // Get the remaining space we can use to grow our columns
        var remainingSpace = width - totalMinWidth
        
        return columns.enumerated().map { (index, column) in
            var column = column

            guard visibleColumns.contains(column) else {
                column.actualWidth = 0
                return column
            }
            
            let leadingMargin: CGFloat
            let trailingMargin: CGFloat
            
            if visibleColumns.count == 1 {
                leadingMargin = 0
                trailingMargin = 0
            } else if index == 0 {
                leadingMargin = 0
                trailingMargin = margin / 2
            } else if index == columns.count - 1 {
                leadingMargin = margin / 2
                trailingMargin = 0
            } else {
                leadingMargin = margin / 2
                trailingMargin = margin / 2
            }
            
            // Get the amount we can grow
            let extra = min(column.maximumWidth - column.minimumWidth, remainingSpace) - leadingMargin -  trailingMargin
            
            remainingSpace -= extra
            
            column.actualWidth = column.minimumWidth + extra
            column.leadingMargin = leadingMargin
            column.trailingMargin = trailingMargin
            
            return column
        }
    }
}
