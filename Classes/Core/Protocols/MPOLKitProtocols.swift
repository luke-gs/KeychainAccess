//
//  MPOLKitProtocols.swift
//  Pods
//
//  Created by Pavel Boryseiko on 20/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The recent searches view controller view model (pretty much just a container)
public protocol SearchRecentsViewModel: class {

    /// The title of the view cotroller
    var title: String { get }

    /// Array of recently viewed entities
    var recentlyViewed: EntityBucket { get }

    /// Array of recently searched
    var recentlySearched: [Searchable] { get set }

    // New Stuffs

    weak var delegate: (SearchRecentsViewModelDelegate & UIViewController)? { get set }

    func recentlyViewedItems() -> [FormItem]

    func recentlySearchedItems() -> [FormItem]

}

public protocol SearchRecentsViewModelDelegate: class {

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectPresentable presentable: Presentable)

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectSearchable searchable: Searchable)
    
    func searchRecentsViewModelDidChange(_ searchRecentsViewModel: SearchRecentsViewModel)

}


public class EntitySummaryRecentsViewModel: SearchRecentsViewModel {

    public var recentlyViewed: EntityBucket {
        return UserSession.current.recentlyViewed
    }

    public var recentlySearched: [Searchable] {
        get { return UserSession.current.recentlySearched }
        set { UserSession.current.recentlySearched = newValue }
    }
    
    public weak var delegate: (SearchRecentsViewModelDelegate & UIViewController)?

    public let title: String

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public let userSession: UserSession

    public init(title: String, userSession: UserSession = .current, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.title = title
        self.userSession = userSession
        self.summaryDisplayFormatter = summaryDisplayFormatter
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecentlyViewedUpdate(_:)), name: EntityBucket.didUpdateNotificationName, object: userSession.recentlyViewed)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func recentlyViewedItems() -> [FormItem] {
        var items: [FormItem] = []
        
        if let header = headerItemForRecentlyViewed() {
            items.append(header)
        }

        items += summaryItemsForRecentlyViewed()

        return items
    }

    public func recentlySearchedItems() -> [FormItem] {
        var items: [FormItem] = []

        if let header = headerItemForRecentlySearched() {
            items.append(header)
        }

        items += summaryItemsForRecentlySearched()
        
        return items
    }

    // MARK: - Subclass can override these methods
    
    open func headerItemForRecentlyViewed() -> FormItem? {
        guard (delegate?.traitCollection.horizontalSizeClass ?? .compact) == .compact else { return nil }
        
        let theme = ThemeManager.shared.theme(for: .dark)
        let separatorColor = theme.color(forKey: .separator) ?? .gray
        return HeaderFormItem(text: NSLocalizedString("RECENTLY VIEWED", comment: ""))
            .separatorColor(separatorColor)
    }
    
    open func summaryItemsForRecentlyViewed() -> [FormItem] {
        let isCompact = (delegate?.traitCollection.horizontalSizeClass ?? .compact) == .compact
        
        let theme = ThemeManager.shared.theme(for: .dark)
        let primaryColor = theme.color(forKey: .primaryText)
        let secondaryColor = theme.color(forKey: .secondaryText)
        
        let maximum = 5
        var recentlyViewed = userSession.recentlyViewed.entities
        if recentlyViewed.count > maximum {
            recentlyViewed = Array(recentlyViewed[0...5])
        }
        
        return recentlyViewed.flatMap { entity in
            guard let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }
            return summary.summaryThumbnailFormItem(with: .detail)
                .titleTextColor(!isCompact ? primaryColor : nil)
                .subtitleTextColor(!isCompact ? secondaryColor : nil)
                .detailTextColor(!isCompact ? secondaryColor : nil)
                .onSelection { [weak self] _ in
                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                    self.delegate?.searchRecentsViewModel(self, didSelectPresentable: presentable)
                }
                .width(.dynamic { info in
                    return info.layout.columnContentWidth(forMinimumItemContentWidth: EntityCollectionViewCell.minimumContentWidth(forStyle: .detail), maximumColumnCount: 3, sectionEdgeInsets: info.edgeInsets)
                    })
                .separatorStyle(isCompact ? .indented : .none)
                .accessory(isCompact ? ItemAccessory.disclosure : nil)
        }
    }
    
    open func headerItemForRecentlySearched() -> FormItem? {
        guard (delegate?.traitCollection.horizontalSizeClass ?? .compact) != .compact else { return nil }
        
        return HeaderFormItem(text: NSLocalizedString("RECENTLY SEARCHED", comment: ""))
    }
    
    open func summaryItemsForRecentlySearched() -> [FormItem] {
        let assetManager = AssetManager.shared
        
        return userSession.recentlySearched.flatMap { searchable -> FormItem in
            return SubtitleFormItem()
                .title(searchable.text?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "[Recently Searched] - No search term"))
                .subtitle(searchable.type?.ifNotEmpty() ?? NSLocalizedString("(No Search Category)", comment: "[Recently Searched] - No search category"))
                .labelSeparation(2.0)
                .image(searchable.imageKey != nil ? assetManager.image(forKey: searchable.imageKey!) : nil)
                .accessory(ItemAccessory.disclosure)
                .width(.column(1))
                .highlightStyle(.fade)
                .onSelection { [weak self] _ in
                    guard let `self` = self else { return }
                    self.delegate?.searchRecentsViewModel(self, didSelectSearchable: searchable)
            }
        }
    }
    
    // MARK: - Private
    
    @objc private func handleRecentlyViewedUpdate(_ notification: Notification) {
        delegate?.searchRecentsViewModelDidChange(self)
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
