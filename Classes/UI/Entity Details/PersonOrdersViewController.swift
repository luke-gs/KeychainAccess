//
//  PersonOrdersViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import UIKit

open class PersonOrdersViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            orders = person?.interventionOrders
        }
    }
    
    private var orders: [InterventionOrder]? {
        didSet {
            let orderCount = orders?.count ?? 0
            sidebarItem.count = UInt(orderCount)
            
            hasContent = orderCount > 0
            collectionView?.reloadData()
        }
    }
    
    public override init() {
        super.init()
        
        hasContent = false
        
        title = NSLocalizedString("Orders", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormFolder",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormFolderFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Orders Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("This person has no related orders", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return orders?.isEmpty ?? true ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        //        cell.highlightStyle     = .fade
        //        cell.selectionStyle     = .fade
        //        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        //
        let order = orders![indexPath.item]
        
        if let type = order.type {
            cell.titleLabel.text = String(format: NSLocalizedString("%@ Order", bundle: .mpolKit, comment: "Order Title"), type.localizedCapitalized)
        } else {
            cell.titleLabel.text = NSLocalizedString("Order (Unknown Type)", bundle: .mpolKit, comment: "")
        }
        
        if let servedDate = order.servedDate {
            cell.subtitleLabel.text = String(format: NSLocalizedString("Date served: %@", bundle: .mpolKit, comment: ""), DateFormatter.mediumNumericDate.string(from: servedDate))
        } else {
            cell.subtitleLabel.text = NSLocalizedString("Date served unknown", bundle: .mpolKit, comment: "")
        }
        
        cell.detailLabel.text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu."
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            let orderCount = orders?.count ?? 0
            if orderCount > 0 {
                let baseString = orderCount > 1 ? NSLocalizedString("%d ORDERS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ORDER", bundle: .mpolKit, comment: "")
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
        let height = CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
        
        return height
    }

    
}
