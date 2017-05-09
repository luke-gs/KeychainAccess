//
//  SearchRecentsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 4/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let maxRecentViewedCount = 6

class SearchRecentsViewController: FormCollectionViewController {
    
    weak var delegate: SearchRecentsViewControllerDelegate?
    
    
    override init() {
        super.init()
        formLayout.wantsOptimizedResizeAnimation = false
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.register(EntityCollectionViewCell.self)
            collectionView.register(CollectionViewFormSubtitleCell.self)
            collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
            collectionView.register(RecentEntitiesBackgroundView.self,          forSupplementaryViewOfKind: collectionElementKindSectionBackground)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.horizontalSizeClass != (previousTraitCollection?.horizontalSizeClass ?? .unspecified) {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return traitCollection.horizontalSizeClass == .compact ? 1 : 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            if indexPath.section == 0 && traitCollection.horizontalSizeClass != .compact {
                header.text = NSLocalizedString("RECENTLY VIEWED", comment: "")
            } else {
                header.text = NSLocalizedString("RECENTLY SEARCHED", comment: "")
            }
            return header
        case collectionElementKindSectionBackground:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: RecentEntitiesBackgroundView.self, for: indexPath)
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            cell.style              = .detail
            cell.titleLabel.text    = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.detailLabel.text   = "Southbank VIC 3006"
            cell.imageView.image    = #imageLiteral(resourceName: "Avatar 1")
            cell.alertColor         = AlertLevel.high.color
            cell.alertCount         = 9
            cell.highlightStyle     = .fade
            cell.sourceLabel.text   = "DS1"
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.titleLabel.text    = "Citizen John"
            cell.subtitleLabel.text = "Person"
            cell.accessoryView      = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
            cell.highlightStyle     = .fade
            cell.imageView.image    = .personOutline
            cell.preferredLabelSeparation = 2.0
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        
        let theme = Theme.current
        if indexPath.section == 0 && traitCollection.horizontalSizeClass != .compact && theme.isDark == false,
            let header = view as? CollectionViewFormExpandingHeaderView {
            header.separatorColor = theme.colors[.AlternateSeparator]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let entityCell = cell as? EntityCollectionViewCell {
            let theme = Theme.current
            if theme.isDark {
                entityCell.subtitleLabel.textColor = primaryTextColor
            } else {
                let primaryColor = theme.colors[.AlternatePrimaryText]
                entityCell.titleLabel.textColor    = primaryColor
                entityCell.subtitleLabel.textColor = primaryColor
                entityCell.detailLabel.textColor   = theme.colors[.AlternateSecondaryText]
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            delegate?.searchRecentsController(self, didSelectRecentEntity: nil)
        default:
            delegate?.searchRecentsController(self, didSelectRecentSearch: nil)
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section, givenSectionWidth: width)
        
        if section == 0 && traitCollection.horizontalSizeClass != .compact {
            inset.top    = 10.0
            inset.bottom = 10.0
        }
        
        return inset
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            return layout.columnContentWidth(forMinimumItemContentWidth: EntityCollectionViewCell.minimumContentWidth(forStyle: .detail), sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets)
        default:
            return sectionWidth
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection)
        default:
            return 40.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, wantsBackgroundInSection section: Int) -> Bool {
        return section == 0 && traitCollection.horizontalSizeClass != .compact
    }
    
}


protocol SearchRecentsViewControllerDelegate: class {
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: Any?)
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: Any?)
    
}


private class RecentEntitiesBackgroundView: UICollectionReusableView, DefaultReusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "RecentContactsBanner"))
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
}

