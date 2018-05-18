//
//  ManageCallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View controller for managing the current callsign status
open class ManageCallsignStatusViewController: SubmissionFormBuilderViewController, ManageCallsignStatusViewModelDelegate {

    open let viewModel: ManageCallsignStatusViewModel

    /// Stack view for action buttons
    open var buttonsView: DialogActionButtonsView!

    // MARK: - Initializers

    public init(viewModel: ManageCallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - View lifecycle

    override open func viewDidLoad() {
        // Set super properties
        navTitles = (viewModel.navTitle(), viewModel.navSubtitle())
        loadingManager.errorView.titleLabel.text = NSLocalizedString("Failed to Update Status", comment: "")

        super.viewDidLoad()

        createSubviews()
        createConstraints()

        // Update when callsign view model changes
        viewModel.callsignViewModel.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open func createSubviews() {
        var actions = [DialogAction]()
        for (index, buttonText) in viewModel.actionButtons.enumerated() {
            actions.append(DialogAction(title: buttonText, handler: { [weak self] (action) in
                self?.viewModel.didTapActionButtonAtIndex(index)
            }))
        }
        buttonsView = DialogActionButtonsView(actions: actions)
        view.addSubview(buttonsView)
    }

    open func createConstraints() {
        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
        ])
    }

    /// Override loading state handling to also disable buttons
    open override func setLoadingState(_ state: LoadingStateManager.State) {
        super.setLoadingState(state)
        buttonsView.isHidden = state != .loaded
    }

    /// Perform actual submit logic
    open override func performSubmit() -> Promise<Void> {
        return viewModel.callsignViewModel.submit()
    }

    open func callsignDidChange() {
        reloadForm()
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        // We show items in 2 columns when compact
        builder.forceLinearLayoutWhenCompact = false

        // Show current incident with header if set
        let listViewModel = viewModel.incidentListViewModel
        if let listViewModel = listViewModel {
            builder += HeaderFormItem(text: NSLocalizedString("Current Incident", comment: "").uppercased(), style: .plain)
            builder += IncidentSummaryFormItem(viewModel: listViewModel)
                .separatorStyle(.none)
                .selectionStyle(.none)
                .accessory(ItemAccessory.disclosure)
                .onSelection({ [unowned self] cell in
                    // Present the incident split view controller
                    if let viewModel = listViewModel.createItemViewModel() {
                        self.present(TaskItemScreen.landing(viewModel: viewModel))
                    }
                })
        }

        // Show callsign statuses
        for sectionIndex in 0..<viewModel.callsignViewModel.numberOfSections() {
            // Show header if text
            if let headerText = viewModel.callsignViewModel.headerText(at: sectionIndex), !headerText.isEmpty {
                builder += HeaderFormItem(text: headerText)
            }

            // Add each status item
            for rowIndex in 0..<viewModel.callsignViewModel.numberOfItems(for: sectionIndex) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                if let item = viewModel.callsignViewModel.item(at: indexPath) {
                    let item = CallsignStatusFormItem(text: item.title, image: item.image)
                        .selected(viewModel.callsignViewModel.selectedIndexPath == indexPath)
                        .highlightStyle(.fade)
                        .onSelection { [weak self] cell in
                            self?.selectCallsignStatus(at: indexPath)
                        }

                    // Remove top padding for first section if incident shown
                    if sectionIndex == 0 && listViewModel != nil {
                        item.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
                    } else {
                        item.layoutMargins = UIEdgeInsets(top: 16.0, left: 24.0, bottom: 0.0, right: 24.0)
                    }
                    builder += item
                }
            }
        }
    }

    open func selectCallsignStatus(at indexPath: IndexPath) {
        guard indexPath != self.viewModel.callsignViewModel.selectedIndexPath else { return }

        // Update the selected index path and process any user input required
        firstly {
            return self.viewModel.callsignViewModel.setSelectedIndexPath(indexPath)
        }.done { [weak self] _ in
            self?.reloadForm()
        }.catch { error in
            AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
        }
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension ManageCallsignStatusViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        reloadForm()
    }
}

