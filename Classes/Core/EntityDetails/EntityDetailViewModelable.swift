//
//  PersonDetailsViewModelable.swift
//  MPOLKit
//
//  Created by RUI WANG on 28/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A delegate for updating the view
public protocol EntityDetailViewModelDelegate: class {

    /// Asks the delegate to update the sidebar count
    func updateSidebarItemCount(_ count: UInt)

    /// Asks the delegate to update content uploading state
    func updateLoadingState(_ state: LoadingStateManager.State)

    /// Asks the delegate to refresh the container view
    func reloadData()

    /// update sidebar alert color 
    func updateSidebarAlertColor(_ color: UIColor?)

    /// update no-content details, the title and subtitle
    func updateNoContentDetails(title: String?, subtitle: String?)

    /// update filter bar button item activity
    func updateFilterBarButtonItemActivity()
}

/// A blank implementation to avoid optional def in the protocol
extension EntityDetailViewModelDelegate {
    public func updateSidebarItemCount(_ count: UInt) { }
    public func updateLoadingState(_ state: LoadingStateManager.State) { }
    public func reloadData() { }
    public func updateSidebarAlertColor(_ color: UIColor?) { }
    public func updateNoContentDetails(title: String? = nil, subtitle: String? = nil) { }
    public func updateFilterBarButtonItemActivity() { }
}

/// A detail viewModel protocol
public protocol EntityDetailViewModelable {

    associatedtype DetailsType

    var sections: [DetailsType] { get }
    var collapsedSections: Set<Int> { get set }

    weak var delegate: EntityDetailViewModelDelegate? { get }

    mutating func updateCollapsed(for sections: [Int])
    func isExpanded(at section: Int) -> Bool

    func numberOfItems(for section: Int) -> Int
    func numberOfSections() -> Int
    func item(at index: Int) -> DetailsType?
}

/// Default implementation for accessing data model
extension EntityDetailViewModelable {

    public func numberOfItems(for section: Int = 0) -> Int {
        return sections.count
    }

    public func numberOfSections() -> Int {
        return sections.isEmpty ? 0 : 1
    }

    public func item(at index: Int) -> DetailsType? {
        return sections[ifExists: index]
    }

    public mutating func updateCollapsed(for sections: [Int]) {
        sections.forEach {
            if collapsedSections.contains($0) {
                collapsedSections.remove($0)
            } else {
                collapsedSections.insert($0)
            }
        }
    }

    public func isExpanded(at section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }
}
