//
//  IncidentResourcesViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentResourcesViewModel {
    
    // Convenience, public init
    public init() {}
    
    // MARK: - Abstract
    
    open lazy var sections: [CADGroupedFormCollectionSectionViewModel<ResourceOfficerViewModel, IncidentCallsignViewModel>] = {
        return [
            CADGroupedFormCollectionSectionViewModel(title: "Patrol: P24 (2)",
                                                     header: IncidentCallsignViewModel(title: "P24 (2)", subtitle: "At Incident"),
                                              items: [
                                                ResourceOfficerViewModel(title: "Dean McCrae", subtitle: "Senior Constable  :  #820904  :  Gold License", badgeText: "DRIVER", commsEnabled: (text: true, call: true, video: false)),
                                                ResourceOfficerViewModel(title: "Sarah Worrall", subtitle: "Constable  :  #800560  :  Silver License", badgeText: nil, commsEnabled: (text: true, call: true, video: true)),
                                                ])
        ]
    }()
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        MPLRequiresConcreteImplementation()
    }
    
    /// Content title shown when no results
    open func noContentTitle() -> String? {
        MPLRequiresConcreteImplementation()
    }
    
    open func noContentSubtitle() -> String? {
        MPLRequiresConcreteImplementation()
    }
    
    // MARK: - Data Source
    
    private var collapsedSections: Set<Int> = []
    
    open func numberOfSections() -> Int {
        return sections.count
    }
    
    open func numberOfItems(for section: Int) -> Int {
        if let sectionViewModel = sections[ifExists: section], !collapsedSections.contains(section) {
            return sectionViewModel.items.count
        }
        return 0
    }
    
    open func item(at indexPath: IndexPath) -> ResourceOfficerViewModel? {
        if let sectionViewModel = sections[ifExists: indexPath.section] {
            // Remove offset to account for header
            return sectionViewModel.items[ifExists: indexPath.row - 1]
        }
        return nil
    }

    open func headerItem(at indexPath: IndexPath) -> IncidentCallsignViewModel? {
        if let sectionViewModel = sections[ifExists: indexPath.section], indexPath.row == 0 {
            return sectionViewModel.header
        }
        return nil
    }
    
    // MARK: - Group Headers
    
    open func shouldShowExpandArrow() -> Bool {
        return true
    }
    
    open func isHeaderExpanded(at section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }
    
    open func toggleHeaderExpanded(at section: Int) {
        if let itemIndex = collapsedSections.index(of: section) {
            collapsedSections.remove(at: itemIndex)
        } else {
            collapsedSections.insert(section)
        }
    }
    
    open func headerText(at section: Int) -> String? {
        if let sectionViewModel = sections[ifExists: section] {
            return sectionViewModel.title.uppercased()
        }
        return nil
    }
    
//
//    /// Create the view controller for this view model
//    public func createViewController() -> ResourceOfficerListViewController {
//        return ResourceOfficerListViewController(viewModel: self)
//    }
//
//    /// Lazy var for creating view model content
//    private lazy var data: [CADFormCollectionSectionViewModel<ResourceOfficerViewModel>] = {
//        return [
//            CADFormCollectionSectionViewModel(title: "Patrol: P24 (2)",
//                                              items: [
//                                                ResourceOfficerViewModel(title: "Dean McCrae", subtitle: "Senior Constable  :  #820904  :  Gold License", badgeText: "DRIVER", commsEnabled: (text: true, call: true, video: false)),
//                                                ResourceOfficerViewModel(title: "Sarah Worrall", subtitle: "Constable  :  #800560  :  Silver License", badgeText: nil, commsEnabled: (text: true, call: true, video: true)),
//                                                ])
//        ]
//    }()
//
//    // MARK: - Override
//
//    override open func sections() -> [CADFormCollectionSectionViewModel<ResourceOfficerViewModel>] {
//        return data
//    }
//
//    /// The title to use in the navigation bar
//    override open func navTitle() -> String {
//        return NSLocalizedString("Officers", comment: "Officers sidebar title")
//    }
//
//    /// Content title shown when no results
//    override open func noContentTitle() -> String? {
//        return NSLocalizedString("No Officers Found", comment: "")
//    }
//
//    override open func noContentSubtitle() -> String? {
//        return nil
//    }
    
}

