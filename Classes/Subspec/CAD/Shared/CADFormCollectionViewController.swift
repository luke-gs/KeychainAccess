//
//  CADFormCollectionViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Abstract base class for CAD form collection view controllers
open class CADFormCollectionViewController<ItemType>: FormCollectionViewController {

    public let viewModel: CADFormCollectionViewModel<ItemType>

    // MARK: - Abstract

    open func cellType() -> CollectionViewFormCell.Type {
        MPLRequiresConcreteImplementation()
    }

    open func decorate(cell: CollectionViewFormCell, with viewModel: ItemType) {
        MPLRequiresConcreteImplementation()
    }

    // MARK: - Initializers

    public init(viewModel: CADFormCollectionViewModel<ItemType>) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navTitle()

        self.viewModel.delegate = self
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
        collectionView.register(cellType())
        
        sectionsUpdated()
    }

    // MARK: - UICollectionViewDataSource

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: cellType(), for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            decorate(cell: cell, with: item)
        }
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

    // Reload the content in the collection view. Can be overridden in subclass
    open func reloadContent() {
        collectionView?.reloadData()
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension CADFormCollectionViewController: CADFormCollectionViewModelDelegate {

    public func sectionsUpdated() {
        // Update loading state
        loadingManager.state = viewModel.numberOfSections() == 0 ? .noContent : .loaded

        // Reload content
        reloadContent()
    }

    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
