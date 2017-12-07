//
//  IncidentAssociationsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationsViewController: CADFormCollectionViewController<EntitySummaryDisplayable> {
    
    private let listStateItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .list), style: .plain, target: nil, action: nil)

    override public init(viewModel: CADFormCollectionViewModel<EntitySummaryDisplayable>) {
        super.init(viewModel: viewModel)
        
        // TODO: Add red dot
        sidebarItem.image = AssetManager.shared.image(forKey: .association)
        
        navigationItem.rightBarButtonItem = listStateItem
        
        listStateItem.target = self
        listStateItem.action = #selector(toggleThumbnails)
        listStateItem.imageInsets = .zero
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(EntityCollectionViewCell.self)
        collectionView?.register(EntityListCollectionViewCell.self)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - Thumbnail support
    
    private var wantsThumbnails: Bool = false {
        didSet {
            guard wantsThumbnails != oldValue else { return }
            
            listStateItem.image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)
            
            if traitCollection.horizontalSizeClass != .compact {
                collectionView?.reloadData()
            }
        }
    }
    
    private var shouldShowGrid: Bool {
        return wantsThumbnails && traitCollection.horizontalSizeClass != .compact
    }
    
    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            if wantsThumbnails {
                collectionView?.reloadData()
            }
            navigationItem.rightBarButtonItems = isCompact ? nil : [listStateItem]
        }
    }
    
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        if shouldShowGrid {
            return EntityCollectionViewCell.self
        } else {
            return EntityListCollectionViewCell.self
        }
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: EntitySummaryDisplayable) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.accessoryView = nil
        
        if let cell = cell as? EntityListCollectionViewCell {
            cell.decorate(with: viewModel)
        } else if let cell = cell as? EntityCollectionViewCell {
            cell.decorate(with: viewModel)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if shouldShowGrid {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
        }
        return collectionView.bounds.width
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let _ = viewModel.item(at: indexPath) {
            if shouldShowGrid {
                return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection)
            } else {
                return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
            }
        }
        return 0
    }

}
