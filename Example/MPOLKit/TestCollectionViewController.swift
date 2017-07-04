//
//  TestCollectionViewController.swift
//  MPOLKit-Example
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class TestCollectionViewController: FormCollectionViewController, FilterViewControllerDelegate  {
    
    var inserted = false
    
    var text: String? {
        didSet {
            if let cell = self.collectionView?.cellForItem(at: IndexPath(item: 0 , section: 0)) as? CollectionViewFormCell {
                cell.setRequiresValidation(text != nil, validationText: text, animated: true)
            } else {
                collectionView?.performBatchUpdates({
                    self.formLayout.invalidateLayout()
                })
            }
        }
    }
    
    override init() {
        super.init()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: Bundle(for: CollectionViewFormLayout.self), compatibleWith: nil), style: .plain, target: self, action: #selector(filterItemDidSelect(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
        collectionView?.register(CollectionViewFormValueFieldCell.self)
        collectionView?.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.text = "Test"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
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
        
        if indexPath.item == 0 && indexPath.section == 0 {
            cell.setRequiresValidation(text != nil, validationText: text, animated: false)
        } else {
            cell.setRequiresValidation(false, validationText: nil, animated: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Kj", subtitle: "Kj", inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0, let text = self.text {
            return CollectionViewFormCell.heightForValidationAccessory(withText: text, contentWidth: contentWidth, compatibleWith: traitCollection)
        }
        return 0.0
    }
    
    
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        
        let dateRange = FilterDateRange(title: "Date Range", startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        
        let list = FilterList(title: "Checkbox", displayStyle: .checkbox, options: ["High", "Medium", "Low"], selectedOptions: [])
        
        let filterVC = FilterViewController(options: [dateRange, list])
        filterVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = item
        }
        
        present(navController, animated: true)
    }
    
    func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
    }
    
}

extension String: Pickable {
    
    public var title: String? {
        return self
    }
    
    public var subtitle: String? {
        return nil
    }
}

