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

    public func updateRepresentations() {
        let sources = detailViewModel.sources!

        sources.forEach {
            let source = $0.serverSourceName
            if let result = detailViewModel.results[source] {
                updateDetailSectionsAvailability(result.state == .finished)
            }
        }

        updateSourceItems()
    }

    open var selectedSource: EntitySource {
        didSet {
            if selectedSource == oldValue {
                return
            }

            updateHeaderView()
        }
    }

    private let headerView = SidebarHeaderView(frame: .zero)
    fileprivate let detailViewModel: EntityDetailSectionsViewModel

    public init(entity: MPOLKitEntity, sources: [EntitySource], dataSource: EntityDetailSectionsDataSource) {

        detailViewModel = EntityDetailSectionsViewModel(entity: entity, sources: sources, dataSource: dataSource)

        selectedSource = sources.first! //TODO: Fixme

        let detailVCs = detailViewModel.detailSectionsViewControllers as? [UIViewController]

        super.init(detailViewControllers: detailVCs ?? [])

        detailViewModel.delegate = self

        title = "Details"
        updateSourceItems()
        updateHeaderView()

        sidebarViewController.title = NSLocalizedString("Details", comment: "")
        sidebarViewController.headerView = headerView
    }


    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detailViewModel.performFetch()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int) {
        // TODO: Implement
    }

    open override func sidebarViewController(_ controller: SidebarViewController, didRequestToLoadSourceAt index: Int) {
        let selectedSource = detailViewModel.dataSource(at: index)

        if let requestedSourceLoadState = detailViewModel.results[selectedSource.serverSourceName]?.state, requestedSourceLoadState != .idle {
            // Did not select an unloaded source. Update the source items just in case, and then return out.
            updateSourceItems()
            return
        }
    }

    // MARK: - Private methods

    @objc private func refreshControlDidActivate(_ control: UIRefreshControl) {
        // TODO: Actually refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            control.endRefreshing()
        }
    }

    /// Updates the source items and selection in the bar. Call this method when
    /// representations update.
    private func updateSourceItems() {

        sidebarViewController.sourceItems = detailViewModel.sources!.map {
            let itemState: SourceItem.State

            if let fetchResult = detailViewModel.results[$0.serverSourceName] {
                switch fetchResult.state {
                case .idle:
//                case .loaded(let entity):
                    // WARNING: NYI
//                    itemState = .loaded(count: entity.actionCount, color: entity.alertLevel?.color)
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
        let index = detailViewModel.sources.index(where: { $0 == selectedSource })
        sidebarViewController.selectedSourceIndex = index

    }

    /// Updates the header view with the details for the latest selected representation.
    /// Call this methodwhen the selected representation changes.
    private func updateHeaderView() {
        var displayableEntity: EntityDetailDisplayable?
        let result = detailViewModel.results[selectedSource.serverSourceName]

        if result == nil {
            displayableEntity = detailViewModel.entity as? EntityDetailDisplayable
        } else {
            displayableEntity = result?.entity as? EntityDetailDisplayable
        }

        guard let entity = displayableEntity else { return }
        guard let summaryDisplayable = entity as? EntitySummaryDisplayable else { return }

        headerView.captionLabel.text = entity.entityDisplayName?.localizedUppercase

        if let (thumbnail, _) = summaryDisplayable.thumbnail(ofSize: .small) {
            headerView.iconView.image = thumbnail
        }

        headerView.titleLabel.text = summaryDisplayable.title

        if let lastUpdated = entity.lastUpdatedString {
            headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }
    }

    private func updateDetailSectionsAvailability(_ isAvailable: Bool) {
        sidebarViewController.sidebarTableView?.allowsSelection = isAvailable
    }

}

extension EntityDetailSplitViewController: EntityDetailSectionsDelegate {

    public func EntityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
    }

    public func EntityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        self.detailViewModel.performFetch()
    }

}
