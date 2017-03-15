//
//  TestCollectionViewController.swift
//  MPOLKit-Example
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormTextFieldCell.self, for: indexPath)
        
        cell.titleLabel.text =  "Test Title \(indexPath.item + 1)"
        cell.textField.placeholder = "Testing placeholder \(indexPath.item + 1)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
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
        // It just so happens that our demo size goal from the creatives for the content view should be 40.0.
        // We've tested (and should unit test) that our sizing methods with default settings and single line detail hand back this value.
        return 40.0
    }
    
    
}

extension UICollectionReusableView: DefaultReusable {
}
