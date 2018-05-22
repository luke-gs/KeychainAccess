//
//  EntityDetailSplitViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol EntityDetailSplitViewControllerDelegate: class {
    
    func entityDetailSplitViewController<Details, Summary>(_ entityDetailSplitViewController: EntityDetailSplitViewController<Details, Summary>, didPresentEntity entity: MPOLKitEntity)
}

open class EntityDetailSplitViewController<Details: EntityDetailDisplayable, Summary: EntitySummaryDisplayable>: SidebarSplitViewController {

    private let headerView = SidebarHeaderView(frame: .zero)
    fileprivate let detailViewModel: EntityDetailSectionsViewModel
    
    public weak var delegate: EntityDetailSplitViewControllerDelegate?

    public init(viewModel: EntityDetailSectionsViewModel) {

        detailViewModel = viewModel

        let detailVCs = detailViewModel.detailSectionsViewControllers as? [UIViewController]

        super.init(detailViewControllers: detailVCs ?? [])

        detailViewModel.delegate = self

        title = NSLocalizedString("Details", comment: "")
        updateSourceItems()
        updateHeaderView()

        regularSidebarViewController.title = title
        regularSidebarViewController.headerView = headerView

        detailViewModel.selectedSource = viewModel.selectedSource
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
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
        guard source != detailViewModel.selectedSource else { return }

        if let result = detailViewModel.results[source.serverSourceName] {
            detailViewModel.selectedSource = source
            detailViewModel.setSelectedResult(fetchResult: result)
        }
        updateEverything()
    }

    open override func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
        let source = detailViewModel.sources[index]
        fetchEntityDetailsFor(source)
    }
    
    /// Used to perform any last checks/tasks when back button is pressed
    override open func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        // The entity details will be pushed off the stack i.e: dismissed
        if parent == nil {
            
            for case let vc as DismissEntityDetailsControllerProtocol in detailViewControllers {
                vc.entityDetailsControllerWillDismiss()
            }
        }
    }

    // MARK: - Override methods

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String? {
        // Ask the data source for an appropriate title
        if traitCollection.horizontalSizeClass == .compact {
            if let title =  detailViewModel.summary?.title {
                return title
            }
        }
        // Use title of split VC
        return title
    }

    // MARK: - Private methods

    fileprivate func fetchDetailsForAllOtherSources() {
        guard detailViewModel.shouldAutomaticallyFetchFromSubsequentDatasources == true else { return }
        guard detailViewModel.results[detailViewModel.selectedSource.serverSourceName]?.state == .finished else { return }

        let sources = detailViewModel.sources.filter { source in
            guard let fetchState = detailViewModel.results[source.serverSourceName]?.state else { return true }
            return source != detailViewModel.selectedSource && fetchState == .idle
        }

        sources.forEach { fetchEntityDetailsFor($0) }
    }

    fileprivate func fetchEntityDetailsFor(_ source: EntitySource) {
        detailViewModel.performSubsequentFetch(for: source)
    }


    fileprivate func updateEverything() {
        detailViewControllers = detailViewModel.detailSectionsViewControllers as! [UIViewController]
        selectedViewController = detailViewControllers.first

        updateRepresentations()
        updateHeaderView()
        updateSourceItems()
    }

    /// Enables/Disables sidebar items based on whether or not its source is updating.
    fileprivate func updateRepresentations() {
        let sources = detailViewModel.sources

        sources.forEach {
            let source = $0.serverSourceName
            if let result = detailViewModel.results[source] {
                updateDetailSectionsAvailability(result.state == .finished)
                if result.state == .finished,
                    detailViewModel.selectedSource == $0,
                    let entity = result.entity,
                    detailViewModel.currentEntity == entity {
                    delegate?.entityDetailSplitViewController(self, didPresentEntity: entity)
                }
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
                        let entity = fetchResult.entity {
                        let displayable = Details(entity)
                        itemState = .loaded(count: displayable.alertBadgeCount, color: displayable.alertBadgeColor ?? .lightGray)
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
    fileprivate func updateHeaderView() {
        let entity = detailViewModel.currentEntity

        let detailDisplayable = Details(entity)
        headerView.captionLabel.text = detailDisplayable.entityDisplayName?.localizedUppercase

        if let summaryDisplayable = detailViewModel.summary {
            if let thumbnailInfo = summaryDisplayable.thumbnail(ofSize: .small) {
                headerView.iconView.setImage(with: thumbnailInfo)
            }

            headerView.titleLabel.text = summaryDisplayable.title
        }

        if let lastUpdated = detailDisplayable.lastUpdatedString {
            headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }
        
        // Relayout as header view may have changed size
        regularSidebarViewController.sidebarTableView?.reloadData()
    }

    private func updateDetailSectionsAvailability(_ isAvailable: Bool) {
        super.allowDetailSelection = isAvailable
    }
}

// MARK: - DetailViewModel Delegate

extension EntityDetailSplitViewController: EntityDetailSectionsDelegate {

    public func entityDetailSectionsDidAddResults(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
        updateSourceItems()
        updateHeaderView()
    }

    public func entityDetailSectionsDidUpdateResults(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
        updateSourceItems()
        updateHeaderView()
        fetchDetailsForAllOtherSources()
    }

    public func entityDetailSectionDidSelectRetryDownload(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        updateRepresentations()
        updateSourceItems()
        updateHeaderView()
    }
}

@objc public protocol DismissEntityDetailsControllerProtocol: class {
    func entityDetailsControllerWillDismiss()
}
