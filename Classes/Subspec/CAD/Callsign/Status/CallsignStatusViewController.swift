//
//  CallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class CallsignStatusViewController: IntrinsicHeightFormBuilderViewController {

    open let viewModel: CallsignStatusViewModel

    // MARK: - Initializers

    public init(viewModel: CallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Set title and initial background color
        title = viewModel.navTitle()

        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        view.backgroundColor = theme.color(forKey: .background)!
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
        self.formLayout.invalidateLayout()
    }

    // MARK: - Form

    open override func construct(builder: FormBuilder) {
        // We show items in 2 columns when compact
        builder.forceLinearLayoutWhenCompact = false

        for sectionIndex in 0..<viewModel.numberOfSections() {
            // Show header if text
            if let headerText = viewModel.headerText(at: sectionIndex), !headerText.isEmpty {
                builder += HeaderFormItem(text: headerText)
            }

            // Add each status item
            for rowIndex in 0..<viewModel.numberOfItems(for: sectionIndex) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                if let item = viewModel.item(at: indexPath) {
                    builder += CallsignStatusFormItem(text: item.title, image: item.image)
                        .selected(viewModel.selectedIndexPath == indexPath)
                        .displayMode(viewModel.displayMode)
                }
            }
        }
    }

    // MARK: - UICollectionViewDelegate

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != viewModel.selectedIndexPath {
            firstly {
                // Attempt to change state
                return viewModel.setSelectedIndexPath(indexPath)
                }.done { [weak self] _ in
                    // Reload the collection view to show new selection. The manage callsign view will update
                    // in response to the callsign being changed, but the incident popover wont
                    self?.reloadForm()
                }.catch { error in
                    AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CallsignStatusViewController {

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

// MARK: - CADFormCollectionViewModelDelegate
extension CallsignStatusViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        reloadForm()
    }
}

