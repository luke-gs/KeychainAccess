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

class TestCollectionViewController: FormCollectionViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormTextFieldCell.self)
        collectionView?.register(CollectionViewFormTextViewCell.self)
        collectionView?.register(CollectionViewFormMPOLHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView?.collectionViewLayout.invalidateLayout()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormTextViewCell.self, for: indexPath)
        
        cell.titleLabel.text =  "Test Title \(indexPath.item + 1)"
        //cell.textView.text = "Testing text \(indexPath.item + 1)"
        cell.textView.placeholderLabel.text = "Testing placeholder \(indexPath.item + 1)"
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormMPOLHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        return .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return sectionWidth
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormTextViewCell.minimumContentHeight(withTitle: "Test Title \(indexPath.item + 1)", text: "Testing text \(indexPath.item + 1)", inWidth: itemWidth, compatibleWidth: traitCollection)
    }
    
    
}

extension UICollectionReusableView: DefaultReusable {
}
