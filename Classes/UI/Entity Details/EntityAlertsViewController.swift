//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAlertsViewController: EntityDetailCollectionViewController {
    
    private var statusDotCache: [Alert.Level: UIImage] = [:]
    
    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            let sidebarItem = self.sidebarItem
            
            guard var alerts = entity?.alerts, alerts.isEmpty == false else {
                self.sections = []
                sidebarItem.count = 0
                return
            }
            
            alerts.sort(by: { $0.level.rawValue > $1.level.rawValue })
            
            sidebarItem.count = UInt(alerts.count)
            sidebarItem.alertColor = alerts.first?.level.color
            
            var sections: [[Alert]] = []
            while let firstAlertLevel = alerts.first?.level {
                if let firstDifferentIndex = alerts.index(where: { $0.level != firstAlertLevel }) {
                    sections.append(Array(alerts.dropFirst(firstDifferentIndex)))
                } else {
                    sections.append(alerts)
                    alerts.removeAll()
                }
            }
            self.sections = sections
        }
    }
    
    private var sections: [[Alert]] = [[]] {
        didSet {
            hasContent = sections.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    public override init() {
        super.init()
        title = "Alerts"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAlert",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAlertFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Alerts Found", comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let alert = sections[indexPath.section][indexPath.item]
        
        let alertLevel = alert.level
        if let cachedImage = statusDotCache[alertLevel] {
            cell.imageView.image = cachedImage
        } else {
            let image = UIImage.statusDot(withColor: alertLevel.color)
            statusDotCache[alertLevel] = image
            cell.imageView.image = image
        }
        
        cell.titleLabel.text    = alert.title
        cell.detailLabel.text = alert.description
        
        if let date = alert.effectiveDate {
            cell.subtitleLabel.text = NSLocalizedString("Effective from ", comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            cell.subtitleLabel.text = NSLocalizedString("Effective date unknown", comment: "")
        }
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            let alerts = sections[indexPath.section]
            let alertCount = alerts.count
            if alertCount > 0 {
                let alertLevel = alerts.first!.level
                header.text = "\(alertCount) \(alertLevel.localizedTitle.uppercased(with: nil)) " + (alertCount > 1 ? NSLocalizedString("ALERTS", comment: "") : NSLocalizedString("ALERT", comment: ""))
            } else {
                header.text = nil
            }
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let alertCell = cell as? CollectionViewFormDetailCell {
            alertCell.titleLabel.textColor    = primaryTextColor
            alertCell.subtitleLabel.textColor = secondaryTextColor
            alertCell.detailLabel.textColor   = primaryTextColor
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let height = CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
        
        return height
    }
    
    
    // MARK: - Private
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        var noContentSubtitle = NSLocalizedString("This entity has no alerts", comment: "")
        if let entity = entity {
            noContentSubtitle = noContentSubtitle.replacingOccurrences(of: "entity", with: type(of: entity).localizedDisplayName.lowercased(with: nil))
        }
        label.text = noContentSubtitle
    }
    
}

