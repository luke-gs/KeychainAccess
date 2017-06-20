//
//  PersonCriminalHistoryViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A view controller for presenting a person's criminal history.
open class PersonCriminalHistoryViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            criminalHistory = person?.criminalHistory
        }
    }
    
    private var criminalHistory: [CriminalHistory]? {
        didSet {
            let orderCount = criminalHistory?.count ?? 0
            sidebarItem.count = UInt(orderCount)
            
            hasContent = orderCount > 0
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        
        hasContent = false
        
        title = NSLocalizedString("Criminal History", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormFolder",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormFolderFilled", in: .mpolKit, compatibleWith: nil)
        
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
        
        noContentTitleLabel?.text = NSLocalizedString("No Criminal History Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("This person has no criminal history", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return criminalHistory?.isEmpty ?? true ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criminalHistory?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let history = criminalHistory![indexPath.item]
        let text = cellText(for: history)
        
        cell.titleLabel.text = text.title
        cell.subtitleLabel.text = text.subtitle
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            let orderCount = criminalHistory?.count ?? 0
            if orderCount > 0 {
                let baseString = orderCount > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, orderCount)
            } else {
                header.text = nil
            }
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let history = criminalHistory![indexPath.item]
        let text = cellText(for: history)
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: text.title, subtitle: text.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private
    
    private func cellText(for history: CriminalHistory) -> (title: String, subtitle: String) {
        var offenceCountText = ""
        if let offenceCount = history.offenceCount {
            offenceCountText = "(\(offenceCount)) "
        }
        
        let lastOccurredDateString: String
        if let lastOccurred = history.lastOccurred {
            lastOccurredDateString = DateFormatter.mediumNumericDate.string(from: lastOccurred)
        } else {
            lastOccurredDateString = NSLocalizedString("Unknown", bundle: .mpolKit, comment: "Unknown date")
        }
        
        let title = offenceCountText + (history.offenceDescription?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", bundle: .mpolKit, comment: ""))
        let subtitle = String(format: NSLocalizedString("Last occurred: %@", bundle: .mpolKit, comment: ""), lastOccurredDateString)
        
        return (title, subtitle)
    }
    
}
