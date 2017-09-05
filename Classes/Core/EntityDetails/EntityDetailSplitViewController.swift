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

    public var fetchResults: [String: EntityFetchResult] = [:] {
        didSet {
            updateRepresentations()
        }
    }

    public func updateRepresentations() {
        let sources = detailViewModel.sources!

       sources.forEach {
        let source = $0.serverSourceName
            if let result = fetchResults[source] {
                var isContentAvailable = false

                switch result.state {
                case .fetching:
                    representations[source] = .loading
                case .finished:
                    isContentAvailable = true
                    if let _ = result.error {
                        representations[source] = .notAvailable
                    } else {
                        representations[source] = .loaded(result.result!)
                    }
                case .idle:
                    representations[source] = .notLoaded
                }
                updateDetailSectionsAvailability(isContentAvailable)
            }
        }
    }

    public enum EntityLoad: Equatable {
        case loaded(MPOLKitEntity)
        case loading
        case notLoaded
        case notAvailable
    }

    open var selectedRepresentation: MPOLKitEntity {
        didSet {
            if selectedRepresentation == oldValue {
                return
            }

            assert(representations.values.contains(.loaded(selectedRepresentation)),
                   "selectedRepresentation must be a representation stored in the representations property.")
            updateHeaderView()
        }
    }

    open var representations: [String: EntityLoad] = ["mpol": .notLoaded] {

        didSet {
            if representations == oldValue {
                return
            }

            if let selectedSource = selectedRepresentation.serverTypeRepresentation {
                if let newLoad = representations[selectedSource], case .loaded(let newRepresentation) = newLoad {
                    if newRepresentation != selectedRepresentation {
                        // representation has changed.
                        selectedRepresentation = newRepresentation
                    }
                } else {
                    // TODO: selected representation has been deleted
                }
            }

            updateSourceItems()
        }
    }

    private let headerView = SidebarHeaderView(frame: .zero)
    fileprivate let detailViewModel: EntityDetailSectionsViewModel

    public init(entity: MPOLKitEntity, sources: [EntitySource], dataSource: EntityDetailSectionsDataSource) {
//         Make view model
        detailViewModel = EntityDetailSectionsViewModel(entity: entity, sources: sources, dataSource: dataSource)
        representations = ["mpol": .loaded(entity)] //WARNING: Fix this

        selectedRepresentation = entity

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

        if let requestedSourceLoadState = representations[selectedSource.serverSourceName], requestedSourceLoadState != .notLoaded {
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
        let sources = detailViewModel.sources!
//
        sidebarViewController.sourceItems = sources.map {
            let itemState: SourceItem.State
//
            if let loadingState = representations[$0.serverSourceName] {
                switch loadingState {
                case .loaded(let entity):
                    // WARNING: NYI
//                    itemState = .loaded(count: entity.actionCount, color: entity.alertLevel?.color)
                    itemState = .loaded(count: 1, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
                case .loading:
                    itemState = .loading
                case .notLoaded:
                    itemState = .notLoaded
                case .notAvailable:
                    itemState = .notAvailable
                }
            } else {
                itemState = .notLoaded
            }
//
            return SourceItem(title: $0.localizedBarTitle, state: itemState)
        }
//
//        if let source = selectedRepresentation.source {
//            sidebarViewController.selectedSourceIndex = sources.index(of: source)
//        } else {
//            sidebarViewController.selectedSourceIndex = nil
//        }

    }

    /// Updates the header view with the details for the latest selected representation.
    /// Call this methodwhen the selected representation changes.
    private func updateHeaderView() {

//        headerView.captionLabel.text = type(of: selectedRepresentation).localizedDisplayName.localizedUppercase

        let entity = selectedRepresentation as! EntitySummaryDisplayable
        if let (thumbnail, _) = entity.thumbnail(ofSize: .small) {
            headerView.iconView.image = thumbnail
        }

        headerView.titleLabel.text = entity.title
        let lastUpdatedString: String
//        if let lastUpdated = selectedRepresentation.lastUpdated {
//            lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
//        } else {
            lastUpdatedString = NSLocalizedString("Unknown", comment: "Unknown Date")
//        }
        headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdatedString
    }

    private func updateDetailSectionsAvailability(_ isAvailable: Bool) {
        sidebarViewController.sidebarTableView?.allowsSelection = isAvailable
    }


}


extension EntityDetailSplitViewController: EntityDetailSectionsDelegate {

    public func EntityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        self.fetchResults = EntityDetailSectionsViewModel.results
    }

    public func EntityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        self.detailViewModel.performFetch()
    }

}

public func == (lhs: EntityDetailSplitViewController.EntityLoad, rhs: EntityDetailSplitViewController.EntityLoad) -> Bool {
    switch (lhs, rhs) {
    case (.loaded(let lhsEntity), .loaded(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.loading, .loading), (.notAvailable, .notAvailable):
        return true
    default:
        return false
    }
}
