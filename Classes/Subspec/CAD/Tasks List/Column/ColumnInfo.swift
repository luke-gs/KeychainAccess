//
//  ColumnInfo.swift
//  MPOLKit
//
//  Created by Kyle May on 13/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct ColumnInfo {

    /// `ColumnInfo` initialized with zero width
    public static let zero = ColumnInfo(minimumWidth: 0, maximumWidth: 0)
    
    /// Minimum width of the column
    public var minimumWidth: CGFloat
    
    /// Maxmimum width of the column
    public var maximumWidth: CGFloat

    /// Actual calculated width of the column
    public var actualWidth: CGFloat = 0
    
    init(minimumWidth: CGFloat, maximumWidth: CGFloat) {
        self.minimumWidth = minimumWidth
        self.maximumWidth = maximumWidth
    }
    
    public static func calculateWidths(for columns: [ColumnInfo], in width: CGFloat) -> [ColumnInfo] {
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
        
        return visibleColumns.map { column -> ColumnInfo? in
            if remainingSpace > 0 {
                // Get the amount we can grow
                let extra = min(column.maximumWidth - column.minimumWidth, remainingSpace)
                remainingSpace -= extra
                
                var column = column
                column.actualWidth = column.minimumWidth + extra
                return column
            }
            
            return nil
        }.removeNils()
    }
}
