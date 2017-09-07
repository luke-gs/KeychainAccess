//
//  EntityAssociationsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EntityAssociationsViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            viewModel.entity = entity
        }
    }
    
    private lazy var viewModel: EntityAssociationsViewModel = {
        var vm = EntityAssociationsViewModel()
        vm.delegate = self
        return vm
    }()
    
    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue {
                return
            }
            
            listStateItem.image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)
            
            viewModel.style = wantsThumbnails ? .grid : .list
            
            if traitCollection.horizontalSizeClass != .compact {
                collectionView?.reloadData()
            }
        }
    }
    
    private let listStateItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .list), style: .plain, target: nil, action: nil)
    
    public override init() {
        super.init()
        title = "Associations"
        
        sidebarItem.image = AssetManager.shared.image(forKey: .association)
        
        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.5, left: 8.0, bottom: 14.5, right: 8.0)
        formLayout.distribution = .none
        
        listStateItem.target = self
        listStateItem.action = #selector(toggleThumbnails)
        listStateItem.imageInsets = .zero
        
        let filterBarItem = FilterBarButtonItem(target: nil, action: nil)
        filterBarItem.isEnabled = false
        navigationItem.rightBarButtonItems = [filterBarItem]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("EntityAssociationsViewController does not support NSCoding.")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Associations Found", comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(EntityListCollectionViewCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            let item = viewModel.item(at: indexPath.section)!
            header.text = item.title
            header.showsExpandArrow = false
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let associate = viewModel.associate(at: indexPath)
        let style = viewModel.style
        
        if style == .list || isCompact {
            let cell = collectionView.dequeueReusableCell(of: EntityListCollectionViewCell.self, for: indexPath)
            cell.decorate(with: associate)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            
           /// cell.configure(for: associate, style: .hero)
            cell.style = self.entityStyle(for: style)

            cell.decorate(with: associate)
            cell.highlightStyle = .fade
            
            return cell
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let listCell = cell as? EntityListCollectionViewCell {
            listCell.titleLabel.textColor = primaryTextColor
            listCell.subtitleLabel.textColor = secondaryTextColor
            listCell.separatorColor = separatorColor
        } else {
            super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
//    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // Ultimate workaround...
//        let associate = sections[indexPath.section].associate(at: indexPath.item)
//        let userInfo: [String: Any] = ["selectedEntity": associate, "viewController" : self]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AssociateDidTapEntity"), object: self, userInfo: userInfo)
//    }
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
        inset.top    = 4.0
        inset.bottom = 0
        return inset
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let style = viewModel.style
        if style == .grid && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: self.entityStyle(for: style))
        }
        return collectionView.bounds.width
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let style = viewModel.style

        if style == .grid && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: self.entityStyle(for: style), compatibleWith: traitCollection) - 12.0
        } else {
            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
    }
    
    private func entityStyle(for style: SearchResultStyle) -> EntityCollectionViewCell.Style {
        return viewModel.style == .grid ? .hero : .detail
    }
    
    private func updateNoContentSubtitle() {
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        loadingManager.noContentView.subtitleLabel.text = String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }
    
}

extension EntityAssociationsViewController: EntityDetailsViewModelDelegate {
    public func updateSidebarItemCount(_ count: UInt) {
        sidebarItem.count = count
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
}

