//
//  EventsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventsListViewController: FormCollectionViewController {
    
    override init() {
        super.init()
        title = NSLocalizedString("Involvements", comment: "Title")
        
        tabBarItem.image = #imageLiteral(resourceName: "iconFormOccurrence")
        tabBarItem.selectedImage = #imageLiteral(resourceName: "iconFormOccurrenceFilled")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = self.collectionView!
        collectionView.register(EventListCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: EventListCell.self, for: indexPath)
        cell.titleLabel.text = "Street Check"
        cell.subtitleLabel.text = "4 - 12 Langridge St, Collingwood VIC 3066"
        cell.actionLabel.text = "Open Event"
        cell.actionSubtitleLabel.text = "Saved at 8:45 AM"
        return cell
    }
    
    
    // MARK: - Collection view delegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let eventCell = cell as? EventListCell {
            eventCell.actionLabel.textColor = collectionView.tintColor
            eventCell.actionSubtitleLabel.textColor = eventCell.subtitleLabel.textColor
        }
    }
    
}



// This will move to the kit. Standby for a rename and shift.
private class EventListCell: CollectionViewFormSubtitleCell {
    
    let actionLabel = UILabel(frame: .zero)
    
    let actionSubtitleLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        highlightStyle = .fade
        
        actionLabel.adjustsFontForContentSizeCategory = true
        actionSubtitleLabel.adjustsFontForContentSizeCategory = true
        
        actionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        actionSubtitleLabel.font = subtitleLabel.font
        
        let contentView = self.contentView
        contentView.addSubview(actionLabel)
        contentView.addSubview(actionSubtitleLabel)
        
        accessoryView = FormDisclosureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let displayScale = traitCollection.currentDisplayScale
        let contentRect = self.contentRect()
        let accessoryInset = CollectionViewFormCell.accessoryContentInset
        
        var actionSize = actionLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        var actionSubtitleSize = actionSubtitleLabel.sizeThatFits(CGSize(width: contentRect.width, height: .greatestFiniteMagnitude))
        
        // `UILabel.sizeThatFits(_:)` can ignore the width when the line count is limited. Cap it.
        actionSize.width = min(actionSize.width, contentRect.width)
        actionSubtitleSize.width = min(actionSubtitleSize.width, contentRect.width)
        
        let actionLabelSeparation = (actionSize.isEmpty || actionLabel.isHidden) || (actionSubtitleSize.isEmpty || actionSubtitleLabel.isHidden) ? 0.0 : labelSeparation.rounded(toScale: displayScale)
        let actionLabelContentSize = CGSize(width: max(actionSize.width, actionSize.height),
                                            height: actionSize.height + actionSubtitleSize.height + actionLabelSeparation)
        
        var actionFrame = CGRect(origin: CGPoint(x: 0.0, y: (contentRect.midY - (actionLabelContentSize.height / 2.0)).rounded(toScale: displayScale)), size: actionSize)
        var actionSubtitleFrame = CGRect(origin: CGPoint(x: 0.0, y: actionFrame.maxY + actionLabelSeparation), size: actionSubtitleSize)
        
        if isRightToLeft {
            actionFrame.origin.x = contentRect.minX
            actionSubtitleFrame.origin.x = contentRect.minX
        } else {
            actionFrame.origin.x = contentRect.maxX - actionSize.width
            actionSubtitleFrame.origin.x = contentRect.maxX - actionSubtitleSize.width
        }
        
        actionLabel.frame = actionFrame
        actionSubtitleLabel.frame = actionSubtitleFrame
        
        if actionLabelContentSize.isEmpty {
            return
        }
        
        var titleFrame = titleLabel.frame
        var subtitleFrame = subtitleLabel.frame
        
        if isRightToLeft {
            let endOfActionContent = (contentRect.minX + actionLabelContentSize.width + (accessoryInset * 2.0)).rounded(toScale: displayScale)
            
            let titleDifference = endOfActionContent - titleFrame.origin.x
            if titleDifference >~ 0.0 {
                titleFrame.size.width -= titleDifference
                titleFrame.origin.x += titleDifference
            }
            let subtitleDifference = endOfActionContent - subtitleFrame.origin.x
            if subtitleDifference >~ 0.0 {
                subtitleFrame.size.width -= subtitleDifference
                subtitleFrame.origin.x += subtitleDifference
            }
        } else {
            let endOfActionContent = (contentRect.maxX - actionLabelContentSize.width - (accessoryInset * 2.0)).rounded(toScale: displayScale)
            
            let titleDifference = titleFrame.maxX - endOfActionContent
            if titleDifference >~ 0 {
                titleFrame.size.width -= titleDifference
            }
            
            let subtitleDifference = subtitleFrame.maxX - endOfActionContent
            if subtitleDifference > 0 {
                subtitleFrame.size.width -= subtitleDifference
            }
        }
        
        titleLabel.frame = titleFrame
        subtitleLabel.frame = subtitleFrame
    }
    
}
