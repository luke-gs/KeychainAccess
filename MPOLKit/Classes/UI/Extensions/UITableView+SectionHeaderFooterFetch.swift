//
//  UITableView+SectionHeaderFooterFetch.swift
//  MPOLKit
//
//  Created by Rod Brown on 13/4/17.
//
//

import UIKit

extension UITableView {
    
    /// The indexes of all visible sections headers.
    public var indexesForVisibleSectionHeaders: IndexSet {
        // Note: We can't just use indexPathsForVisibleRows, since it won't return index paths for empty sections.
        
        var visibleSectionIndexes = IndexSet()
        let style  = self.style
        let bounds = self.bounds
        
        for i in 0..<numberOfSections {
            // In plain style, the section headers are floating on the top, so the section header is visible if any part of the section's rect is still visible.
            // In grouped style, the section headers are not floating, so the section header is only visible if it's actualy rect is visible.
            
            let headerRect = style == .plain ? rect(forSection: i) : rectForHeader(inSection: i)
            if headerRect.intersects(bounds) {
                visibleSectionIndexes.insert(i)
            } else if headerRect.minY > bounds.maxY {
                break
            }
        }
        return visibleSectionIndexes
    }
    
    /// The indexes of all visible sections footers.
    public var indexesForVisibleSectionFooters: IndexSet {
        
        var visibleSectionIndexes = IndexSet()
        let style  = self.style
        let bounds = self.bounds
        
        for i in 0..<numberOfSections {
            // In plain style, the section footers are floating on the top, so the footer is visible if any part of the section's rect is still visible.
            // In grouped style, the section footers are not floating, so the section header is only visible if it's actualy rect is visible.
            
            let footerRect = style == .plain ? rect(forSection: i) : rectForFooter(inSection: i)
            if footerRect.intersects(bounds) {
                visibleSectionIndexes.insert(i)
            } else if footerRect.minY > bounds.maxY {
                break
            }
        }
        return visibleSectionIndexes
    }
    
    public var visibleSectionHeaderViews: [UIView] {
        return indexesForVisibleSectionHeaders.flatMap { self.headerView(forSection: $0) }
    }
    
    public var visibleSectionFooterViews: [UIView] {
        return indexesForVisibleSectionFooters.flatMap { self.footerView(forSection: $0) }
    }
    
}
