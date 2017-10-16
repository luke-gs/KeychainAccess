//
//  IncidentResourcesViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class IncidentResourcesViewController<ItemType, HeaderType>: FormCollectionViewController {

    let viewModel: IncidentResourcesViewModel
    
    public init(viewModel: IncidentResourcesViewModel) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navTitle()
        
        // TODO: Get real image
        sidebarItem.image = AssetManager.shared.image(forKey: .association)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if let header = viewModel.headerItem(at: indexPath) {
            cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        } else if let item = viewModel.item(at: indexPath) {
            cell = collectionView.dequeueReusableCell(of: OfficerCell.self, for: indexPath)
        } else {
            fatalError("Unable to find item in view model at index path \(indexPath)")
        }
        
        ////            decorate(cell: cell, with: item)
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // Create collapsible section header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = viewModel.headerText(at: indexPath.section)
            if viewModel.shouldShowExpandArrow() {
                header.showsExpandArrow = true
                header.tapHandler = { [weak self] headerView, indexPath in
                    guard let `self` = self else { return }
                    self.viewModel.toggleHeaderExpanded(at: indexPath.section)
                    self.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
                    headerView.setExpanded(self.viewModel.isHeaderExpanded(at: indexPath.section), animated: true)
                }
                header.isExpanded = viewModel.isHeaderExpanded(at: indexPath.section)
            }
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    /// Provide default header height
    /// Use @objc here as otherwise this is not called if not overridden in subclass!
    @objc open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
//
//    func decorate(cell: CollectionViewFormCell, with viewModel: ItemType) {
//        cell.highlightStyle = .fade
//        cell.selectionStyle = .fade
//        cell.separatorStyle = .indented
//        cell.accessoryView = nil
//
//        if let cell = cell as? EntityListCollectionViewCell {
//            cell.decorate(with: viewModel)
//        }
//    }
//
//    // MARK: - Override
//
//    override open func cellType() -> CollectionViewFormCell.Type {
//        return EntityListCollectionViewCell.self
//    }
//
//    override open func decorate(cell: CollectionViewFormCell, with viewModel: EntitySummaryDisplayable) {
//        cell.highlightStyle = .fade
//        cell.selectionStyle = .fade
//        cell.separatorStyle = .indented
//        cell.accessoryView = nil
//
//        if let cell = cell as? EntityListCollectionViewCell {
//            cell.decorate(with: viewModel)
//        }
//    }
//
//    // MARK: - UICollectionViewDelegate
//
//    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        // TODO: present details?
//    }
//
//    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
//        if let _ = viewModel.item(at: indexPath) {
//            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
//        }
//        return 0
//    }

}
