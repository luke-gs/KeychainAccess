//
//  EntityDetailSplitViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class EntityDetailSplitViewController: SidebarSplitViewController {

    private let headerView = SidebarHeaderView(frame: .zero)
    fileprivate let detailViewModel: EntityDetailSectionsViewModel

    public init(dataSource: EntityDetailSectionsDataSource) {

        detailViewModel = EntityDetailSectionsViewModel(dataSource: dataSource)

        let detailVCs = detailViewModel.detailSectionsViewControllers as? [UIViewController]

        super.init(detailViewControllers: detailVCs ?? [])

        detailViewModel.delegate = self

        title = "Details"
        updateSourceItems()
        updateHeaderView()

        regularSidebarViewController.title = NSLocalizedString("Details", comment: "")
        regularSidebarViewController.headerView = headerView
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController {
            detailViewModel.performFetch()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    // MARK: - SideBar Delegate

    open override func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
        let source = detailViewModel.sources[index]
        detailViewModel.selectedSource = source

        if let result = detailViewModel.results[source.serverSourceName] {
            detailViewModel.setSelectedResult(fetchResult: result)
        }

        updateHeaderView()
    }

    open override func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
        let selectedSource = detailViewModel.sources[index]

        if let requestedSourceLoadState = detailViewModel.results[selectedSource.serverSourceName]?.state, requestedSourceLoadState != .idle {
            // Did not select an unloaded source. Update the source items just in case, and then return out.
            updateSourceItems()
            return
        }
    }

    // MARK: - Override methods

    open override func regularTitle() -> String? {
        // Use the sidebar title
        return NSLocalizedString("Details", comment: "")
    }

    open override func compactTitle() -> String? {
        // Use the title of the entity, as not showing sidebar with details in compact mode
        return detailViewModel.detailSectionsDataSource.navTitleSuitable(for: traitCollection)
    }

    // MARK: - Private methods

    /// Enables/Disables sidebar items based on whether or not its source is updating.
    fileprivate func updateRepresentations() {
        let sources = detailViewModel.sources

        sources.forEach {
            let source = $0.serverSourceName
            if let result = detailViewModel.results[source] {
                updateDetailSectionsAvailability(result.state == .finished)
            }
        }
    }

    /// Updates the source items and selection in the bar. Call this method when
    /// representations update.
    fileprivate func updateSourceItems() {

        regularSidebarViewController.sourceItems = detailViewModel.sources.map {
            let itemState: SourceItem.State

            if let fetchResult = detailViewModel.results[$0.serverSourceName] {
                switch fetchResult.state {
                case .idle:
                    itemState = .notLoaded

                case .fetching:
                    itemState = .loading

                case .finished:
                    if fetchResult.error == nil,
                        let displayable = fetchResult.entity as? EntityDetailDisplayable {
                        itemState = .loaded(count: displayable.alertBadgeCount, color: displayable.alertBadgeColor)
                    } else {
                        itemState = .notAvailable
                    }
                }
            } else {
                itemState = .notLoaded
            }

            return SourceItem(title: $0.localizedBarTitle, state: itemState)
        }
        let index = detailViewModel.sources.index(where: { $0 == detailViewModel.selectedSource })
        regularSidebarViewController.selectedSourceIndex = index

        // Apply same source items to compact sidebar
        compactSidebarViewController.sourceItems = regularSidebarViewController.sourceItems
        compactSidebarViewController.selectedSourceIndex = regularSidebarViewController.selectedSourceIndex

    }

    /// Updates the header view with the details for the latest selected representation.
    /// Call this methodwhen the selected representation changes.
    private func updateHeaderView() {
        let entity = detailViewModel.currentEntity

        guard let detailDisplayable = entity as? EntityDetailDisplayable else { return }
        guard let summaryDisplayable = entity as? EntitySummaryDisplayable else { return }

        headerView.captionLabel.text = detailDisplayable.entityDisplayName?.localizedUppercase

        if let (thumbnail, _) = summaryDisplayable.thumbnail(ofSize: .small) {
            headerView.iconView.image = thumbnail
        }

        headerView.titleLabel.text = summaryDisplayable.title

        if let lastUpdated = detailDisplayable.lastUpdatedString {
            headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }
    }

    private func updateDetailSectionsAvailability(_ isAvailable: Bool) {
        super.allowDetailSelection = isAvailable
    }

}

// MARK: - DetailViewModel Delegate

extension EntityDetailSplitViewController: EntityDetailSectionsDelegate {

    public func EntityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
        updateSourceItems()
    }

    public func EntityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
        updateSourceItems()
    }

}
