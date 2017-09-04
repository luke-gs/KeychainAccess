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
//        let sources = entityFetch.sources!
//
//       sources.forEach {
//            if let result = fetchResults[$0] {
//                var isContentAvailable = false
//
//                switch result.state {
//                case .fetching:
//                    representations[$0] = .loading
//                case .finished:
//                    isContentAvailable = true
//                    if let _ = result.error {
//                        representations[$0] = .notAvailable
//                    } else {
//                        representations[$0] = .loaded(result.result as! Entity)
//                    }
//                case .idle:
//                    representations[$0] = .notLoaded
//                }
//                updateDetailSectionsAvailability(isContentAvailable)
//            }
//        }
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

//            if let selectedSource = selectedRepresentation.serverTypeRepresentation {
//                if let newLoad = representations[selectedSource], case .loaded(let newRepresentation) = newLoad {
//                    if newRepresentation != selectedRepresentation {
//                        // representation has changed.
//                        selectedRepresentation = newRepresentation
//                    }
//                } else {
//                    // TODO: selected representation has been deleted
//                }
//            }

            updateSourceItems()
        }
    }

    private let headerView = SidebarHeaderView(frame: .zero)
    fileprivate let entityFetch: EntityDetailSectionsViewModel

    public init(entity: MPOLKitEntity) {
//         Make view model
        entityFetch = EntityDetailSectionsViewModel(entity: entity)
//        representations = [.mpol: .loaded(entity)]

        selectedRepresentation = entity

//        let detailVCs = entityFetch.detailsSectionsViewControllers!

        super.init(detailViewControllers: [])

        entityFetch.delegate = self

        title = "Details"
        updateSourceItems()
        updateHeaderView()

        sidebarViewController.title = NSLocalizedString("Details", comment: "")
        sidebarViewController.headerView = headerView
    }


    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        entityFetch.performFetch()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int) {
        // TODO: Implement
    }

    open override func sidebarViewController(_ controller: SidebarViewController, didRequestToLoadSourceAt index: Int) {
        let selectedSource = entityFetch.dataSource(at: index)

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
//        let sources = entityFetch.sources!
//
//        sidebarViewController.sourceItems = sources.map {
//            let itemState: SourceItem.State
//
//            if let loadingState = representations[$0.serverSourceName] {
//                switch loadingState {
//                case .loaded(let entity):
//                    itemState = .loaded(count: entity.actionCount, color: entity.alertLevel?.color)
//                case .loading:
//                    itemState = .loading
//                case .notLoaded:
//                    itemState = .notLoaded
//                case .notAvailable:
//                    itemState = .notAvailable
//                }
//            } else {
//                itemState = .notLoaded
//            }
//
//            return SourceItem(title: $0.localizedBarTitle, state: itemState)
//        }
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
//
//        let entity = selectedRepresentation as! EntitySummaryDisplayable
//        if let (thumbnail, _) = entity.thumbnail(ofSize: .small) {
//            headerView.iconView.image = thumbnail
//        }
//
//        headerView.titleLabel.text = entity.title
//        let lastUpdatedString: String
//        if let lastUpdated = selectedRepresentation.lastUpdated {
//            lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
//        } else {
//            lastUpdatedString = NSLocalizedString("Unknown", comment: "Unknown Date")
//        }
//        headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdatedString
    }

    private func updateDetailSectionsAvailability(_ isAvailable: Bool) {
        sidebarViewController.sidebarTableView?.allowsSelection = isAvailable
    }

    private func headerIconAndMode() -> (image: UIImage?, mode: UIViewContentMode) {
//        switch selectedRepresentation {
//        case let person as Person:
//            return (UIImage.thumbnail(withInitials: person.initials!), .scaleAspectFill) // TODO: Get image from person
//        case _ as Vehicle:
//            return (nil, .scaleAspectFit) // vehicle image
//        default:
            return (nil, .scaleAspectFit)
//        }
    }

}


extension EntityDetailSplitViewController: EntityDetailSectionsDelegate {

    public func EntityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        self.fetchResults = EntityDetailSectionsViewModel.results
    }

    public func EntityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel) {
        self.entityFetch.performFetch()
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
