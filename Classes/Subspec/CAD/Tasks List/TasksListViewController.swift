//
//  TasksListViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for displaying a list of tasks in the left hand side of the CAD split view controller
///
/// This uses FormCollectionViewController for consistent styling.
public class TasksListViewController: FormCollectionViewController {

    public let viewModel: TasksListViewModel

    // MARK: - Initializers

    public init(viewModel: TasksListViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.navTitle()
        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()

        guard let collectionView = self.collectionView else { return }

        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(TasksListItemCell.self)
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: TasksListItemCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            cell.decorate(with: item)
        }
        return cell
    }

    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // Create collapsible section header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = viewModel.headerText(at: indexPath.section)
            header.showsExpandArrow = true
            header.tapHandler = { [weak self] headerView, indexPath in
                guard let `self` = self else { return }
                self.viewModel.toggleHeaderExpanded(at: indexPath.section)
                self.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
                headerView.setExpanded(self.viewModel.isHeaderExpanded(at: indexPath.section), animated: true)
            }
            header.isExpanded = viewModel.isHeaderExpanded(at: indexPath.section)
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
            return TasksListItemCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}

/// Extension of form detail cell that supports decorating using our view model
extension TasksListItemCell {
    public func decorate(with viewModel: TasksListItemViewModel) {
        highlightStyle = .fade
        selectionStyle = .fade
        separatorStyle = .none
        accessoryView = FormAccessoryView(style: .disclosure)

        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        // imageView.image = viewModel.dotImage()
    }
}
