//
//  TestCollectionViewController.swift
//  MPOLKit-Example
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class TestCollectionViewController: FormCollectionViewController  {
    
    var inserted = false
    
    var text: String? {
        didSet {
            if let cell = self.collectionView?.cellForItem(at: IndexPath(item: 0 , section: 0)) as? CollectionViewFormCell {
                cell.setValidationText(text, textColor: .red, animated: true)
                cell.separatorColor = text?.isEmpty ?? true ? Theme.current.colors[.Separator] : .red
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formLayout.pinsGlobalHeaderWhenBouncing = true
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
        collectionView?.register(CollectionViewFormValueFieldCell.self)
        collectionView?.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView?.register(RecentEntitiesBackgroundView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.text = "Test"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.text = nil
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSections(in collection: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100 + (inserted ? 1 : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case collectionElementKindGlobalHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: RecentEntitiesBackgroundView.self, for: indexPath)
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.tintColor = Theme.current.colors[.SecondaryText]
            header.showsExpandArrow = true
            header.text = "1 ACTIVE ALERT"
            header.tapHandler = { (header, ip) in
                header.setExpanded(header.isExpanded == false, animated: true)
            }
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        
        cell.titleLabel.text =  "Test Title \(indexPath.item + 1)"
        cell.placeholderLabel.text = "Testing placeholder \(indexPath.item + 1)"
        
        if indexPath.item % 2 == 0 {
            cell.valueLabel.text = "Testing value \(indexPath.item + 1)"
        } else {
            cell.valueLabel.text = nil
        }
        
        cell.editActions = [CollectionViewFormEditAction(title: "DELETE", color: .destructive, handler: nil)]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Kj", subtitle: "Kj", inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 310.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0, let text = self.text {
            return CollectionViewFormCell.heightForValidationAccessory(withText: text, contentWidth: contentWidth, compatibleWith: traitCollection)
        }
        return 0.0
        
        
    }
    
}

extension UICollectionReusableView: DefaultReusable {
}

private class RecentEntitiesBackgroundView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "RecentContactsBanner"))
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
}

