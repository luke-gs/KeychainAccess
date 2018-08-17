//
//  CollectionViewFormCellsController.swift
//  MPOLKitDemo
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class HeadersBasicFormCellsController: FormCollectionViewController {
    
    enum Section: Int {
        case subtitle
        case valueField
        case textField
        
        static let count: Int = 3
        
        var numberOfCells: Int {
            switch self {
            case .subtitle:   return 1
            case .valueField: return 2
            case .textField:  return 2
            }
        }
        
        var title: String {
            switch self {
            case .subtitle:   return "CollectionViewFormSubtitleCell"
            case .valueField: return "CollectionViewFormValueFieldCell"
            case .textField:  return "CollectionViewFormTextFieldCell"
            }
        }
    }
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        title = "Headers & Basic Form Cells"
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
        collectionView?.register(CollectionViewFormValueFieldCell.self)
        collectionView?.register(CollectionViewFormTextFieldCell.self)
        collectionView?.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
    // MARK: - Collection view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Section(rawValue: section)!.numberOfCells
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.showsExpandArrow = true
            header.text = "HEADER: " + Section(rawValue: indexPath.section)!.title
            header.tapHandler = { (header, ip) in
                header.setExpanded(header.isExpanded == false, animated: true)
            }
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .subtitle:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            
            cell.titleLabel.text = "Title"
            cell.subtitleLabel.text = "Subtitle"
            
            cell.editActions = [CollectionViewFormEditAction(title: "DELETE", color: .destructive, handler: nil)]
            
            return cell
        case .valueField:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            
            cell.titleLabel.text = "Title"
            cell.placeholderLabel.text = "Placeholder"
            
            if indexPath.item % 2 == 0 {
                cell.valueLabel.text = "Value"
            } else {
                cell.valueLabel.text = nil
            }
            
            cell.editActions = [CollectionViewFormEditAction(title: "DELETE", color: .destructive, handler: nil)]
            
            return cell
            
        case .textField:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormTextFieldCell.self, for: indexPath)
            
            cell.titleLabel.text = "Title"
            cell.textField.placeholder = "Placeholder"
            
            if indexPath.item % 2 == 0 {
                cell.textField.text = nil
            } else {
                cell.textField.text = nil
            }
            
            return cell
        }
    }
    
    
    // MARK: - Collection View Delegate Form Layout
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case .subtitle:
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Title", subtitle: "Subtitle", inWidth: itemWidth, compatibleWith: traitCollection)
        case .valueField:
            return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: "Title", value: indexPath.item % 2 == 0 ? "Value" : nil, placeholder: "Placeholder", inWidth: itemWidth, compatibleWith: traitCollection)
        case .textField:
            return CollectionViewFormTextFieldCell.minimumContentHeight(withTitle: "Title", enteredText: indexPath.item % 2 == 0 ? "Value" : nil, placeholder: "Placeholder", inWidth: itemWidth, compatibleWith: traitCollection)
        }
    }
    
}


