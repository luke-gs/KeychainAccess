//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAlertsViewController: EntityDetailCollectionViewController {
    
    // MARK: - Public Properties
    
    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            let sidebarItem = self.sidebarItem
            
            guard var alerts = entity?.alerts?.sorted(by: { ($0.level ?? 0) > ($1.level ?? 0) }), alerts.isEmpty == false else {
                self.sections = []
                sidebarItem.count = 0
                return
            }
            
            alerts.sort {
                ($0.effectiveDate ?? Date.distantPast) > ($1.effectiveDate ?? Date.distantPast)
            }
            
            sidebarItem.count = UInt(alerts.count)
            sidebarItem.alertColor = alerts.first?.level?.color
            
            var sections: [[Alert]] = []
            
            while let firstAlertLevel = alerts.first?.level {
                if let firstDifferentIndex = alerts.index(where: { $0.level != firstAlertLevel }) {
                    let alertLevelSlice = alerts.prefix(upTo: firstDifferentIndex)
                    alerts.removeFirst(firstDifferentIndex)
                    sections.append(Array(alertLevelSlice))
                } else {
                    sections.append(alerts)
                    alerts.removeAll()
                }
            }
            
            self.sections = sections
        }
    }
    
    
    // MARK: - Private properties
    
    private var sections: [[Alert]] = [[]] {
        didSet {
            if oldValue.isEmpty == true && sections.isEmpty == true {
                return
            }
            
            hasContent = sections.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    private var statusDotCache: [Alert.Level: UIImage] = [:]
    
    lazy private var collapsedSections: [String: Set<Alert.Level>] = [:]
    
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Alerts", bundle: .mpolKit, comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAlert",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAlertFilled", in: .mpolKit, compatibleWith: nil)
        
        let filterIcon = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: .mpolKit, compatibleWith: nil), style: .plain, target: nil, action: nil)
        filterIcon.isEnabled = false
        navigationItem.rightBarButtonItem = filterIcon
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Alerts Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let alerts = sections[section]
        let level = alerts.first!.level!
        if collapsedSections[entity!.id]?.contains(level) ?? false {
            // Don't assume there is a collapsed sections here because we should load it lazily.
            return 0
        } else {
            return alerts.count
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()

        let alert = sections[indexPath.section][indexPath.item]
        
        if let alertLevel = alert.level {
            if let cachedImage = statusDotCache[alertLevel] {
                cell.imageView.image = cachedImage
            } else {
                let image = UIImage.statusDot(withColor: alertLevel.color!)
                statusDotCache[alertLevel] = image
                cell.imageView.image = image
            }
        } else  {
            cell.imageView.image = nil
        }
        
        cell.titleLabel.text  = alert.title
        cell.detailLabel.text = alert.details
        
        if let date = alert.effectiveDate {
            cell.subtitleLabel.text = NSLocalizedString("Effective from ", bundle: .mpolKit, comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            cell.subtitleLabel.text = NSLocalizedString("Effective date unknown", bundle: .mpolKit, comment: "")
        }
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            let alerts = sections[indexPath.section]
            let alertCount = alerts.count
            let personId = self.entity!.id
            let level = alerts.first!.level!
            
            if alertCount > 0, let levelDescription = level.localizedDescription(plural: alertCount > 1) {
                header.text = "\(alertCount) \(levelDescription.localizedUppercase) "
                header.showsExpandArrow = true
                
                header.tapHandler = { [weak self] (headerView, indexPath) in
                    guard let `self` = self else { return }
                    
                    var collapsedSections = self.collapsedSections[personId] ?? []
                    if collapsedSections.remove(level) == nil {
                        // This section wasn't in there and didn't remove
                        collapsedSections.insert(level)
                    }
                    self.collapsedSections[personId] = collapsedSections
                    
                    self.collectionView?.reloadData()
                }
                
                header.isExpanded = !(collapsedSections[personId]?.contains(level) ?? false)
            } else {
                header.text = nil
            }
            
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private methods
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        label.text = String(format: NSLocalizedString("This %@ has no alerts", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
}

