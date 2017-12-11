//
//  MPOLKitProtocols.swift
//  Pods
//
//  Created by Pavel Boryseiko on 20/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The recent searches view controller view model (pretty much just a container)
public protocol SearchRecentsViewModel {

    /// The title of the view cotroller
    var title: String { get }

    /// Array of recently viewed entities
    var recentlyViewed: [MPOLKitEntity] { get set }

    /// Array of recently searched
    var recentlySearched: [Searchable] { get set }

    /// Decorate the recently viewed cell
    ///
    /// - Parameters:
    ///   - cell: the cell to decorate
    ///   - indexPath: the indexPath of the cell (most likely will correlate to the recently viewed entities)
    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath)

    /// Summary icon to be used in the recently viewed cells
    ///
    /// - Parameter searchable: the searchable object which will most likely contain the type of entity
    /// - Returns: the image to use
    func summaryIcon(for searchable: Searchable) -> UIImage?


    // New Stuffs

    func recentlyViewedItems() -> [FormItem]

    func recentlySearchedItems() -> [FormItem]

}


public class EntitySummaryRecentsViewModel: SearchRecentsViewModel {

    public var recentlyViewed: [MPOLKitEntity] {
        get {
            return UserSession.current.recentlyViewed
        }

        set {
            UserSession.current.recentlyViewed = newValue
        }
    }

    public var recentlySearched: [Searchable] {
        get {
            return UserSession.current.recentlySearched
        }

        set {
            UserSession.current.recentlySearched = newValue
        }
    }

    public func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) { }

    // New stuffs

    public let title: String

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public let userSession: UserSession

    public var imageForSearchable: ((Searchable) -> UIImage?)?

    public init(title: String, userSession: UserSession = .current, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.title = title
        self.userSession = userSession
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }

    open func recentlyViewedItems() -> [FormItem] {
        return userSession.recentlyViewed.flatMap { entity in
            guard let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }
            return SummaryThumbnailFormItem()
                .style(.detail)
                .category(summary.category)
                .title(summary.title)
                .subtitle(summary.detail1)
                .detail(summary.detail2)
                .badge(summary.badge)
                .badgeColor(summary.iconColor)
                .borderColor(summary.borderColor)
                .image(summary.thumbnail(ofSize: .medium))
//                .onSelection { [weak self] _ in
//                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
//                    self.delegate?.requestToPresent(presentable)
//                }
        }
    }

    open func recentlySearchedItems() -> [FormItem] {
        return userSession.recentlySearched.flatMap { searchable in
            return SubtitleFormItem()
                .title(searchable.text?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "[Recently Searched] - No search term"))
                .subtitle(searchable.type?.ifNotEmpty() ?? NSLocalizedString("(No Search Category)", comment: "[Recently Searched] - No search category"))
                .image(imageForSearchable?(searchable))
        }
    }

    public func summaryIcon(for searchable: Searchable) -> UIImage? {
        return nil
    }

}



/// The main search view model container
///
/// Only reason this really exists is that once we pass this in to MPOLKit's main SearchViewController we don't have control over this object's properties
public protocol SearchViewModel {

    /// A delegate back to the search view controller
    var entityDelegate: EntityDetailsDelegate? { get set }

    /// The recent view model
    var recentViewModel: SearchRecentsViewModel { get }

    /// The data sources to be used
    var dataSources: [SearchDataSource] { get }
    
    /// Creates a presentable for entity
    ///
    /// - Parameter entity: The entity
    /// - Returns: The presentable
    func presentable(for entity: MPOLKitEntity) -> Presentable

}
