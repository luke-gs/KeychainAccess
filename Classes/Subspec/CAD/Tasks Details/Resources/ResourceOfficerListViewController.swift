//
//  ResourceOfficerListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewController: FormCollectionViewController {

    let viewModel: ResourceOfficerListViewModel
    
    public init(viewModel: ResourceOfficerListViewModel) {
        self.viewModel = viewModel
        super.init()
        
        
        title = NSLocalizedString("Officers", bundle: .mpolKit, comment: "")
        // TODO: Get real item
        sidebarItem.image = AssetManager.shared.image(forKey: .entityOfficer)
        
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
//        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
//


        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(OfficerCell.self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: OfficerCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            cell.decorate(with: item)
        }
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // Create collapsible section header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = "\(viewModel.numberOfItems()) OFFICERS"
            
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return OfficerCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}

/// Extension of form detail cell that supports decorating using our view model
extension OfficerCell {
    public func decorate(with viewModel: ResourceOfficerViewModel) {
        highlightStyle = .fade
        selectionStyle = .fade
        separatorStyle = .indented
        accessoryView = nil
        
        let (messageEnabled, callEnabled, videoEnabled) = viewModel.commsEnabled
        
        messageButton.isEnabled = messageEnabled
        callButton.isEnabled = callEnabled
        videoButton.isEnabled = videoEnabled
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        badgeLabel.text = viewModel.badgeText
    }
}
