//
//  CallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View controller for showing callsign statuses as a collection view
open class CallsignStatusViewController: SubmissionFormBuilderViewController {

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

    open override func viewDidLoad() {
        // Set super properties
        title = viewModel.navTitle()
        loadingManager.errorView.titleLabel.text = NSLocalizedString("Failed to Update Status", comment: "")

        super.viewDidLoad()
    }

    open override func updateForLayoutOrTraitChange() {
        // Invalidate the layout so new sizing is performed for callsign status items
        formLayout.invalidateLayout()
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
                        .highlightStyle(.fade)
                        .displayMode(viewModel.displayMode)
                        .onSelection { [weak self] cell in
                            self?.selectCallsignStatus(at: indexPath)
                    }
                }
            }
        }
    }

    open func selectCallsignStatus(at indexPath: IndexPath) {
        guard indexPath != viewModel.selectedIndexPath else { return }

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

    /// Perform actual submit logic
    open override func performSubmit() -> Promise<Void> {
        return viewModel.submit()
    }

}

// MARK: - CADFormCollectionViewModelDelegate
extension CallsignStatusViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        reloadForm()
    }
}

