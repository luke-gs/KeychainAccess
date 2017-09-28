//
//  TimelineCollectionViewFormLayout.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Custom form collection view layout that adds timeline decorators
public class TimelineCollectionViewFormLayout : CollectionViewFormLayout {

    private let timelineKind = "timeline"
    private var timelineRects: [CGRect] = []

    required public init() {
        super.init()
        register(TimelineView.self, forDecorationViewOfKind: timelineKind)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func prepare() {
        super.prepare()

        guard let collectionView = self.collectionView else { return }

        // Prepare layout rects for timelines
        timelineRects.removeAll()
        for section in 0..<collectionView.numberOfSections {
            let sectionItemCount = collectionView.numberOfItems(inSection: section)
            if sectionItemCount > 1 {
                let firstItem = super.layoutAttributesForItem(at: IndexPath(item: 0, section: section))
                let lastItem = super.layoutAttributesForItem(at: IndexPath(item: sectionItemCount - 1, section: section))
                if let firstItem = firstItem, let lastItem = lastItem {
                    // Draw a line from center of first item to center of last item
                    let startY = firstItem.frame.origin.y + firstItem.frame.height / 2
                    let endY = lastItem.frame.origin.y + firstItem.frame.height / 2
                    timelineRects.append(CGRect(x: firstItem.frame.origin.x+35.5, y: startY, width: 1, height: endY - startY))
                }
            }
        }
    }

    public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == timelineKind {
            // Return frame created during prepare
            let atts = UICollectionViewLayoutAttributes(forDecorationViewOfKind:timelineKind, with:indexPath)
            atts.frame = timelineRects[indexPath.section]
            return atts
        }
        return nil
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)

        // Append any timeline decorations that are within the rect being drawed
        for section in 0..<timelineRects.count {
            if let decorationAtts = self.layoutAttributesForDecorationView(ofKind:self.timelineKind, at: IndexPath(item: 0, section: section)) {
                if rect.contains(decorationAtts.frame) {
                    attrs?.append(decorationAtts)
                }
            }
        }
        return attrs
    }
}
