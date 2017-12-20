//
//  CADStatusViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public typealias CADStatusViewModel = CADFormCollectionViewModel<ManageCallsignStatusItemViewModel> & IndexPathSelectable

open class CADStatusViewController: ThemedPopoverViewController {
    
    private let viewModel: CADStatusViewModel
    
    /// Collection view for status items
    open var collectionView: UICollectionView!
    
    /// Flow layout
    open var collectionViewLayout: UICollectionViewFlowLayout!

    // MARK: - Initializers
    
    public init(viewModel: CADStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        createSubviews()
        createConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open func createSubviews() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 0, right: 24)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 10
        
        collectionView = IntrinsicHeightCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(ManageCallsignStatusViewCell.self)
        view.addSubview(collectionView)
    }
    
    open func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - View lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title and initial background color
        title = viewModel.navTitle()
        view.backgroundColor = theme.color(forKey: .background)!
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Forces any loading cell to keep playing the animation.
        collectionView.reloadData()
    }
    
    /// We need to override viewDidLayoutSubviews as well as willTransition due to behaviour of popover controller
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the item size
        self.updateItemSizeForTraits()
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update the item size
            self.updateItemSizeForTraits()
        }, completion: nil)
    }
    
    /// Update the item size based on size class
    open func updateItemSizeForTraits() {
        let availableWidth = collectionView.bounds.width - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right
        if self.isCompact() {
            self.collectionViewLayout.itemSize = CGSize(width: availableWidth / 2, height: 45)
        } else {
            self.collectionViewLayout.itemSize = CGSize(width: availableWidth / 4, height: 75)
        }
        self.collectionViewLayout.invalidateLayout()
    }
    
    open func decorate(cell: ManageCallsignStatusViewCell, with viewModel: ManageCallsignStatusItemViewModel, selected: Bool) {
        cell.titleLabel.text = viewModel.title
        cell.titleLabel.font = .systemFont(ofSize: 13.0, weight: selected ? UIFont.Weight.semibold : UIFont.Weight.regular)
        cell.titleLabel.textColor = theme.color(forKey: .secondaryText)!
        
        cell.imageView.image = viewModel.image
        cell.imageView.tintColor = theme.color(forKey: selected ? .tint : .secondaryText)!
        
        cell.spinner.color = theme.color(forKey: .tint)
    }
    
    // MARK: - Theme
    
    override open func apply(_ theme: Theme) {
        super.apply(theme)
        
        // Theme headers
        let sectionHeaderIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        for indexPath in sectionHeaderIndexPaths {
            if let headerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
                self.collectionView(collectionView, willDisplaySupplementaryView: headerView, forElementKind: UICollectionElementKindSectionHeader, at: indexPath)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CADStatusViewController: UICollectionViewDataSource {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = viewModel.headerText(at: indexPath.section)
            header.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            return header
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let headerView = view as? CollectionViewFormHeaderView {
            headerView.tintColor = theme.color(forKey: .secondaryText)
            headerView.separatorColor = theme.color(forKey: .separator)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ManageCallsignStatusViewCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            decorate(cell: cell, with: item, selected: indexPath == viewModel.selectedIndexPath)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension CADStatusViewController: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), indexPath != viewModel.selectedIndexPath {
            cell.contentView.alpha = 0.5
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CADStatusViewController: UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let headerText = viewModel.headerText(at: section), !headerText.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: CollectionViewFormHeaderView.minimumHeight)
        }
        return .zero
    }
}


// MARK: - CADFormCollectionViewModelDelegate
extension CADStatusViewController: CADFormCollectionViewModelDelegate {
    
    open func sectionsUpdated() {
        collectionView.reloadData()
    }
}

