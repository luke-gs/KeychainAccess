//
//  CallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class CallsignStatusViewController: ThemedPopoverViewController {

    open let viewModel: CallsignStatusViewModel

    /// Collection view for status items
    open var collectionView: UICollectionView!

    /// Flow layout
    open var collectionViewLayout: UICollectionViewFlowLayout!

    /// The index path that is currently loading
    private var loadingIndexPath: IndexPath?

    // MARK: - Initializers

    public init(viewModel: CallsignStatusViewModel) {
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

    // MARK: - Internal

    private func set(loading: Bool, at indexPath: IndexPath) {
        self.loadingIndexPath = loading ? indexPath : nil
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CallsignStatusViewController: UICollectionViewDataSource {

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ManageCallsignStatusViewCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            decorate(cell: cell, with: item, selected: viewModel.selectedIndexPath == indexPath)
        }
        return cell
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

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ManageCallsignStatusViewCell else { return }
        cell.isLoading = indexPath == loadingIndexPath
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let headerView = view as? CollectionViewFormHeaderView {
            headerView.tintColor = theme.color(forKey: .secondaryText)
            headerView.separatorColor = theme.color(forKey: .separator)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CallsignStatusViewController: UICollectionViewDelegateFlowLayout {

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CollectionViewFormHeaderView.minimumHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension CallsignStatusViewController: UICollectionViewDelegate {

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

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != viewModel.selectedIndexPath, loadingIndexPath == nil {

            let oldIndexPath = viewModel.selectedIndexPath!
            set(loading: true, at: indexPath)

            firstly {
                // Attempt to change state
                return viewModel.setSelectedIndexPath(indexPath)
            }.then { _ in
                // Update selection
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath, oldIndexPath])
                    }, completion: nil)
                }
            }.always {
                // Stop animation
                self.set(loading: false, at: indexPath)
            }.catch { error in
                AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension CallsignStatusViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        collectionView.reloadData()
    }

    open func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
