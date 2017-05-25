//
//  PersonCriminalHistoryViewController.swift
//  Pods
//
//  Created by Rod Brown on 23/5/17.
//
//

import UIKit

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
    
    public override init() {
        super.init()
        
        hasContent = false
        
        title = NSLocalizedString("Criminal History", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormFolder",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormFolderFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Criminal History Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("This person has no criminal history", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return criminalHistory?.isEmpty ?? true ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criminalHistory?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.emphasis = .title
        
        let text = textForItem(at: indexPath)
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
    
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let text = textForItem(at: indexPath)
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: text.title, subtitle: text.subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .title)
    }
    
    
    /// MARK: - Private
    
    private func textForItem(at indexPath: IndexPath) -> (title: String, subtitle: String){
        let history = criminalHistory![indexPath.item]
        
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
