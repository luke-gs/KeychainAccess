//
//  ActivityLogViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Activity Log view controller
public class ActivityLogViewController: TimelineFormCollectionViewController {

    private lazy var viewModel: ActivityLogViewModel = {
        let vm = ActivityLogViewModel()
        // vm.delegate = self
        return vm
    }()

    // MARK: - Initializers

    public override init() {
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
        collectionView.register(ActivityLogItemCell.self)
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ActivityLogItemCell.self, for: indexPath)
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
            return ActivityLogItemCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}

/// Extension of form detail cell that supports decorating using our view model
extension ActivityLogItemCell {
    public func decorate(with viewModel: ActivityLogItemViewModel) {
        highlightStyle = .fade
        selectionStyle = .fade
        separatorStyle = .none
        accessoryView = FormAccessoryView(style: .disclosure)

        timeLabel.text = viewModel.timestamp
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        imageView.image = viewModel.dotImage()
    }
}
