//
//  EntityDetailsSplitViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityDetailsSplitViewController: SidebarSplitViewController {
    
    public enum EntityLoad: Equatable {
        case loaded(Entity)
        case loading
        case notLoaded
        case notAvailable
    }
    
    open class func detailViewControllers(for entity: Entity) -> [EntityDetailCollectionViewController] {
        var viewControllers = [
            EntityAlertsViewController(),
            EntityAssociationsViewController(),
            EntityOccurrencesViewController()
        ]
    
        switch entity {
        case _ as Person:
            viewControllers.insert(PersonInfoViewController(), at: 0)
            viewControllers.append(PersonOrdersViewController())
            viewControllers.append(PersonCriminalHistoryViewController())
        default:
            break
        }
        return viewControllers
    }
    
    
    open var sources: [Source] {
        didSet {
            if sources != oldValue {
                updateSourceItems()
            }
        }
    }
    
    open var selectedRepresentation: Entity {
        didSet {
            if selectedRepresentation == oldValue { return }
            
            assert(representations.values.contains(.loaded(selectedRepresentation)),
                   "selectedRepresentation must be a representation stored in the representations property.")
            
            updateHeaderView()

            // TODO
        }
    }
    
    open var representations: [Source: EntityLoad] {
        didSet {
            if representations == oldValue { return }
            
            if let selectedSource = selectedRepresentation.source {
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
    
    private let headerView = EntityDetailsSidebarHeaderView(frame: .zero)
    
    public init(entity: Entity) {
        // TODO: Refactor sources into the current MPOL Context
        
        sources = [.leap]
        representations = [.leap: .loaded(entity)]
        
        selectedRepresentation = entity
                
        let detailVCs = type(of: self).detailViewControllers(for: entity)
        
        detailVCs.forEach { $0.entity = entity }
        
        super.init(detailViewControllers: detailVCs)
        
        title = "Details"
        
        updateSourceItems()
        updateHeaderView()
        
        sidebarViewController.title = NSLocalizedString("Details", comment: "")
        sidebarViewController.headerView = headerView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidActivate(_:)), for: .primaryActionTriggered)
        sidebarViewController.loadViewIfNeeded()
        if #available(iOS 10, *) {
            sidebarViewController.sidebarTableView?.refreshControl = refreshControl
        } else {
            sidebarViewController.sidebarTableView?.addSubview(refreshControl)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int) {
        // TODO
    }
    
    open override func sidebarViewController(_ controller: SidebarViewController, didRequestToLoadSourceAt index: Int) {
        let selectedSource = sources[index]
        
        if let requestedSourceLoadState = representations[selectedSource], requestedSourceLoadState != .notLoaded {
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
    
    /// Updates the source items and selection in the bar.
    ///
    /// Call this method when representations update.
    private func updateSourceItems() {
        sidebarViewController.sourceItems = sources.map {
            let itemState: SourceItem.State
            
            if let loadingState = representations[$0] {
                switch loadingState {
                case .loaded(let entity):
                    itemState = .loaded(count: entity.actionCount, color: entity.alertLevel?.color)
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
            
            return SourceItem(title: $0.localizedBarTitle, state: itemState)
        }
        
        if let source = selectedRepresentation.source {
            sidebarViewController.selectedSourceIndex = sources.index(of: source)
        } else {
            sidebarViewController.selectedSourceIndex = nil
        }
    }
    
    /// Updates the header view with the details for the latest selected representation.
    ///
    /// Call this method when the selected representation changes.
    private func updateHeaderView() {
        headerView.typeLabel.text = type(of: selectedRepresentation).localizedDisplayName.localizedUppercase
        
        let headerIcon = headerIconAndMode()
        headerView.thumbnailView.image = headerIcon.image
        headerView.thumbnailView.contentMode = headerIcon.mode
        
        headerView.titleLabel.text = selectedRepresentation.summary
        
        let lastUpdatedString: String
        if let lastUpdated = selectedRepresentation.lastUpdated {
            lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
        } else {
            lastUpdatedString = NSLocalizedString("Unknown", comment: "Unknown Date")
        }
        headerView.lastUpdatedLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdatedString
    }
    
    private func headerIconAndMode() -> (image: UIImage?, mode: UIViewContentMode) {
        
        switch selectedRepresentation {
        case _ as Person:
            return (#imageLiteral(resourceName: "Avatar 1"), .scaleAspectFill) // TODO: Get image from person
        case _ as Vehicle:
            return (nil, .scaleAspectFit) // vehicle image
        default:
            return (nil, .scaleAspectFit)
        }
    }
    
}

public func ==(lhs: EntityDetailsSplitViewController.EntityLoad, rhs: EntityDetailsSplitViewController.EntityLoad) -> Bool {
    switch (lhs, rhs) {
    case (.loaded(let lhsEntity), .loaded(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.loading, .loading), (.notAvailable, .notAvailable):
        return true
    default:
        return false
    }
}

