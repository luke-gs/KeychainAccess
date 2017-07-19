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
    
    override init() {
        super.init()
        formLayout.pinsGlobalHeaderWhenBouncing = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: Bundle(for: CollectionViewFormLayout.self), compatibleWith: nil), style: .plain, target: self, action: #selector(filterItemDidSelect(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
        collectionView?.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView?.register(RecentEntitiesBackgroundView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSections(in collection: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case collectionElementKindGlobalHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: RecentEntitiesBackgroundView.self, for: indexPath)
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, class: CollectionViewFormHeaderView.self, for: indexPath)
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        
        cell.titleLabel.text =  "Test Title \(indexPath.item + 1)"
        cell.subtitleLabel.text = "Testing placeholder \(indexPath.item + 1)"
        
        if let accessory = cell.accessoryView as? LabeledAccessoryView {
            cell.accessoryView = accessory
        } else {
            let accessory = LabeledAccessoryView()
            accessory.accessoryView = FormDisclosureView()
            accessory.titleLabel.font = .preferredFont(forTextStyle: .subheadline)
            accessory.titleLabel.text = "Select Action"
            accessory.subtitleLabel.text = "Testing placeholder \(indexPath.item + 1)"
            cell.accessoryView = accessory
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let labeledAccessoryView = (cell as? CollectionViewFormCell)?.accessoryView as? LabeledAccessoryView {
            labeledAccessoryView.titleLabel.textColor = tintColor
            labeledAccessoryView.subtitleLabel.textColor = secondaryTextColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Kj", subtitle: "Test", inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        
        let dateRange = FilterDateRange(title: "Date Range", startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        
        let list = FilterList(title: "Checkbox", displayStyle: .detailList, options: ["High", "Medium", "Low"], selectedIndexes: [], allowsNoSelection: true)
        
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
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 200.0
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


private class RecentEntitiesBackgroundView: UICollectionReusableView, DefaultReusable {
    
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
