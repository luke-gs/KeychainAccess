//
//  PersonActionsViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import UIKit

open class PersonActionsViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            actions = person?.actions
        }
    }
    
    private var actions: [Action]? {
        didSet {
            let orderCount = actions?.count ?? 0
            sidebarItem.count = UInt(orderCount)
            
            hasContent = orderCount > 0
            collectionView?.reloadData()
        }
    }
    
    public override init() {
        super.init()
        
        hasContent = false
        
        title = NSLocalizedString("Actions", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormFolder",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormFolderFilled", in: .mpolKit, compatibleWith: nil)
        
        let filterIcon = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: .mpolKit, compatibleWith: nil), style: .plain, target: nil, action: nil)
        filterIcon.isEnabled = false
        navigationItem.rightBarButtonItem = filterIcon
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("PersonActionsViewController does not support NSCoding.")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Actions Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("This person has no related actions", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return actions?.isEmpty ?? true ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let action = actions![indexPath.item]
        
        if let type = action.type {
            cell.titleLabel.text = String(format: NSLocalizedString("%@", bundle: .mpolKit, comment: "Action Title"), type.localizedCapitalized)
        } else {
            cell.titleLabel.text = NSLocalizedString("Action (Unknown Type)", bundle: .mpolKit, comment: "")
        }
        cell.subtitleLabel.text = NSLocalizedString("Date unknown", bundle: .mpolKit, comment: "")
        cell.detailLabel.text = nil
        
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            let orderCount = actions?.count ?? 0
            if orderCount > 0 {
                let baseString = orderCount > 1 ? NSLocalizedString("%d ACTIONS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ACTION", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, orderCount)
            } else {
                header.text = nil
            }
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let height = CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
        
        return height
    }

    
}
