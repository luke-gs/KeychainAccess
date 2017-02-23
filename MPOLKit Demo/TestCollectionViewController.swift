//
//  TestCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let reuseIdentifier = "Cell"

class TestCollectionViewController: UICollectionViewController, CollectionViewDelegateMPOLLayout {

    init() {
        let layout = CollectionViewFormMPOLLayout()
        layout.separatorStyle = .fullWidth
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(EntityCollectionViewCell.self)
        collectionView?.register(CollectionViewFormMPOLHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView?.collectionViewLayout.invalidateLayout()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, class: CollectionViewFormMPOLHeaderView.self, for: indexPath)
        header.tintColor = Theme.current.colors[.SecondaryText]
        header.showsExpandArrow = true
        header.text = "1 ACTIVE ALERT"
        header.tapHandler = { (header, ip) in
            header.setExpanded(header.isExpanded == false, animated: true)
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
        
        cell.imageView.image    = #imageLiteral(resourceName: "Avatar 1")
        cell.titleLabel.text    = "Frost, Deacon H."
        cell.subtitleLabel.text = "27/10/1987 (33 Male)"
        cell.detailLabel.text   = "Williamstown VIC 3016"
        cell.alertColor         = .red
        cell.alertCount         = 8
        cell.sourceLabel.text   = "DS1"
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection)
    }
    
    
}

extension UICollectionReusableView: DefaultReusable {
}
