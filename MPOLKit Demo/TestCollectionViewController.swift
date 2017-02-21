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

class TestCollectionViewController: UICollectionViewController, CollectionViewDelegateFormLayout {

    init() {
        let style = CollectionViewFormBoxedStyle()
        style.wantsSectionSeparators = false
        style.wantsVerticalItemSeparators = false
        style.wantsHorizontalItemSeparators = false
        let layout = CollectionViewFormLayout(style: style)
        layout.distribution = .none
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(EntityCollectionViewCell.self)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
        
        cell.style              = .detail
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
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return EntityCollectionViewCell.minimumContentWidth(forStyle: .detail) + 50.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection)
    }
    
    
}
