//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAlertsViewController: FormCollectionViewController {
    
    public override init() {
        super.init()
        title = "Alerts"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAlert",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAlertFilled", in: .mpolKit, compatibleWith: nil)
        sidebarItem.count = 5
        sidebarItem.alertColor = AlertLevel.medium.color
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormMPOLHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(AlertCollectionViewCell.self)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: AlertCollectionViewCell.self, for: indexPath)
        cell.configure(for: NSObject())
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormMPOLHeaderView.self, for: indexPath)
            header.text = "5 ACTIVE ALERTS"
            header.showsExpandArrow = true
            header.isExpanded = true
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let alertCell = cell as? AlertCollectionViewCell {
            alertCell.titleLabel.textColor    = primaryTextColor
            alertCell.subtitleLabel.textColor = secondaryTextColor
            alertCell.detailLabel.textColor   = primaryTextColor
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormMPOLHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return 88.0
    }
    
}

fileprivate class AlertCollectionViewCell: CollectionViewFormDetailCell {
    
    let alertLevelLabel = RoundedRectLabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let disclosureView = FormDisclosureView()
        accessoryView = disclosureView
        
        alertLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLevelLabel.setContentHuggingPriority(UILayoutPriorityRequired - 1, for: .vertical)
        alertLevelLabel.setContentHuggingPriority(UILayoutPriorityRequired - 1, for: .horizontal)
        alertLevelLabel.textColor = .black
        
        contentView.addSubview(alertLevelLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: alertLevelLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: alertLevelLabel, attribute: .top,      relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriorityDefaultHigh),
            NSLayoutConstraint(item: alertLevelLabel, attribute: .bottom,   relatedBy: .lessThanOrEqual,    toItem: disclosureView, attribute: .top),
            NSLayoutConstraint(item: alertLevelLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: titleLabel,     attribute: .trailing, constant: 8.0),
            NSLayoutConstraint(item: alertLevelLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: subtitleLabel,  attribute: .trailing, constant: 8.0),
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for alert: Any) {
        // TODO: Get alert details
        
        titleLabel.text    = "Wanted For Questioning"
        subtitleLabel.text = "Effective from 21/01/15 - 21/12/14"
        detailLabel.text   = "Individual is wanted for questioning in connection to a confrontation that happed at the Royal Motel, 133-155 Kingsclere Avenue, Keysborough VIC 3173. The event took place on..."
        
        let alertLevel = AlertLevel.medium
        alertLevelLabel.text            = alertLevel.localizedIndicatorTitle
        alertLevelLabel.backgroundColor = alertLevel.color
    }
    
}
