//
//  ColumnInfo.swift
//  MPOLKit
//
//  Created by Kyle May on 13/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct ColumnInfo: Equatable {

    /// `ColumnInfo` initialized with zero width
    public static let zero = ColumnInfo(minimumWidth: 0, maximumWidth: 0)
    
    /// Minimum width of the column
    public var minimumWidth: CGFloat
    
    /// Maxmimum width of the column
    public var maximumWidth: CGFloat

    /// Actual calculated width of the column
    public var actualWidth: CGFloat = 0
    
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
    public static func calculateWidths(for columns: [ColumnInfo], in width: CGFloat) -> [CGFloat] {
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
        
        return columns.map { column in
            guard visibleColumns.contains(column) else {
                return 0
            }
            
            // Get the amount we can grow
            let extra = min(column.maximumWidth - column.minimumWidth, remainingSpace)
            
            remainingSpace -= extra
            
            return column.minimumWidth + extra
        }
    }
}
