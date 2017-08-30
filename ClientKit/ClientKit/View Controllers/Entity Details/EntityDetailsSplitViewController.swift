//
//  EntityDetailsSplitViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import PromiseKit

open class EntityDetailsSplitViewController: SidebarSplitViewController {
    
    public enum EntityLoad: Equatable {
        case loaded(Entity)
        case loading
        case notLoaded
        case notAvailable
    }
    
    open class func detailViewControllers(for entity: Entity) -> [EntityDetailCollectionViewController] {
        /// This is nasty.
        var viewControllers = [
            EntityAlertsViewController(),
            EntityAssociationsViewController(),
            ]
        switch entity {
        case _ as Person:
            viewControllers.insert(PersonInfoViewController(), at: 0)
            viewControllers += [
                PersonOccurrencesViewController(),
             //   PersonActionsViewController(),
             //   PersonCriminalHistoryViewController()
            ]
        case _ as Vehicle:
            viewControllers.insert(VehicleInfoViewController(), at: 0)
            viewControllers.append(VehicleOccurrencesViewController())
        default:
            break
        }
        return viewControllers
    }
    
    private func fetchDetails(for entity: Entity) {
        let infoVC = self.detailViewControllers.first! as! EntityDetailCollectionViewController
        
        infoVC.loadingManager.state = .loading
        
        switch entity {
        case _ as Person:
            let request = PersonFetchParameter(id: entity.id)
            firstly {
                APIManager.shared.fetchEntityDetails(in: MPOLSource.mpol, with: request)
                }.then { [weak self] person -> () in
                    /// unlock the sections and update header & sidebar
                    self?.representations = [.mpol: .loaded(person)]
                    self?.selectedRepresentation = person
                    
                    if let detailVCs = self?.detailViewControllers as? [EntityDetailCollectionViewController] {
                        detailVCs.forEach { $0.entity = person }
                    }
                    
                }.catch(execute: { (error) in
                    
                })
        case _ as Vehicle:
            let request = VehicleFetchParameter(id: entity.id)
            firstly {
                APIManager.shared.fetchEntityDetails(in: MPOLSource.mpol, with: request)
                }.then { [weak self] vehicle -> () in
                    self?.representations = [.mpol: .loaded(vehicle)]
                    self?.selectedRepresentation = vehicle

                    if let detailVCs = self?.detailViewControllers as? [EntityDetailCollectionViewController] {
                        detailVCs.forEach { $0.entity = vehicle }
                    }
                    
                }.catch(execute: { (error) in
                    print("ERROR: \(error.localizedDescription)")
                })
        default:
            break
        }
        
        
        
//        if let result = result {
//            return Promise { fulfill, reject in
//                firstly {
//                    result
//                    }.then { result -> Void in
//                        fulfill(entity)
//                    }.catch { error in
//                        reject(error)
//                }
//            }
//        } else {
//            return nil
//        }
        
    }
    
    
    open var sources: [MPOLSource] {
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
    
    open var representations: [MPOLSource: EntityLoad] {
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
    
    private let headerView = SidebarHeaderView(frame: .zero)
    
    public init(entity: Entity) {
        // TODO: Refactor sources into the current MPOL Context
        
        sources = [.mpol]
        representations = [.mpol: .loaded(entity)]

        selectedRepresentation = entity
        
        let detailVCs = type(of: self).detailViewControllers(for: entity)
        
      ///  detailVCs.forEach { $0.entity = entity }
        
        super.init(detailViewControllers: detailVCs)
        
        fetchDetails(for: entity)
//        if let fetch = fetchDetails(for: entity) {
//            fetch.then { entity -> () in
//                detailVCs.forEach { $0.entity = entity }
//                }.catch { error in
//                    
//            }
//        }
        
        title = "Details"
        
        updateSourceItems()
        updateHeaderView()
        
        sidebarViewController.title = NSLocalizedString("Details", comment: "")
        sidebarViewController.headerView = headerView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidActivate(_:)), for: .primaryActionTriggered)
        sidebarViewController.loadViewIfNeeded()
        sidebarViewController.sidebarTableView?.refreshControl = refreshControl
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
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
    
    /// Updates the source items and selection in the bar. Call this method when
    /// representations update.
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
    /// Call this methodwhen the selected representation changes.
    private func updateHeaderView() {
        
        headerView.captionLabel.text = type(of: selectedRepresentation).localizedDisplayName.localizedUppercase
        /*
        if let headerIcon = selectedRepresentation.thumbnailImage(ofSize: .medium) {
            headerView.iconView.image = headerIcon.image
            headerView.iconView.contentMode = headerIcon.mode
        } else {
            headerView.iconView.image = nil
        }
        */
        // TEMP:
        
        let entity = selectedRepresentation as! EntitySummaryDisplayable
        if let (thumbnail, _) = entity.thumbnail(ofSize: .small) {
            headerView.iconView.image = thumbnail
        }
       /// headerView.iconView.image = #imageLiteral(resourceName: "Avatar 1")
        
        headerView.titleLabel.text = entity.title
        
        let lastUpdatedString: String
        if let lastUpdated = selectedRepresentation.lastUpdated {
            lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
        } else {
            lastUpdatedString = NSLocalizedString("Unknown", comment: "Unknown Date")
        }
        headerView.subtitleLabel.text = NSLocalizedString("Last Updated: ", comment: "") + lastUpdatedString
    }
    
    private func headerIconAndMode() -> (image: UIImage?, mode: UIViewContentMode) {
        switch selectedRepresentation {
        case let person as Person:
            return (UIImage.thumbnail(withInitials: person.initials!), .scaleAspectFill) // TODO: Get image from person
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

