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

    weak var delegate: (SearchRecentsViewModelDelegate & UIViewController)? { get set }

    func recentlyViewedItems() -> [FormItem]

    func recentlySearchedItems() -> [FormItem]

}

public protocol SearchRecentsViewModelDelegate: class {

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectPresentable presentable: Presentable)

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectSearchable searchable: Searchable)

}


public class EntitySummaryRecentsViewModel: SearchRecentsViewModel {

    public var recentlyViewed: EntityBucket {
        return UserSession.current.recentlyViewed
    }

    public var recentlySearched: [Searchable] {
        get { return UserSession.current.recentlySearched }
        set { UserSession.current.recentlySearched = newValue }
    }

    public func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) {
        let entity = recentlyViewed.entities[indexPath.item]

        cell.style = .detail

        if let entity = entity as? EntitySummaryDisplayable {
            cell.decorate(with: entity)
        }
    }

    public func summaryIcon(for searchable: Searchable) -> UIImage? {
        guard let type = searchable.type else { return nil }

        switch type {
        case "Person":
            return AssetManager.shared.image(forKey: .entityPerson)
        case "Vehicle":
            return AssetManager.shared.image(forKey: .entityCar)
        case "Organisation":
            return AssetManager.shared.image(forKey: .location)
        default:
            return AssetManager.shared.image(forKey: .info)
        }
    }

    // New stuffs

    public weak var delegate: (SearchRecentsViewModelDelegate & UIViewController)?

    public let title: String

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public let userSession: UserSession

    public init(title: String, userSession: UserSession = .current, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.title = title
        self.userSession = userSession
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }

    open func recentlyViewedItems() -> [FormItem] {
        let isCompact = (delegate?.traitCollection.horizontalSizeClass ?? .compact) == .compact

        let theme = ThemeManager.shared.theme(for: .dark)
        let separatorColor = theme.color(forKey: .separator) ?? .gray
        let primaryColor = theme.color(forKey: .primaryText)
        let secondaryColor = theme.color(forKey: .secondaryText)

        var items: [FormItem] = []

        if !isCompact {
            items.append(HeaderFormItem(text: NSLocalizedString("RECENTLY VIEWED", comment: ""))
                .separatorColor(separatorColor))
        }

        let maximum = 5
        var recentlyViewed = userSession.recentlyViewed.entities
        if recentlyViewed.count > maximum {
            recentlyViewed = Array(recentlyViewed[0...5])
        }

        items += recentlyViewed.flatMap { entity in
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

        return items
    }

    open func recentlySearchedItems() -> [FormItem] {
        let isCompact = (delegate?.traitCollection.horizontalSizeClass ?? .compact) == .compact

        var items: [FormItem] = []

        if !isCompact {
            items.append(HeaderFormItem(text: NSLocalizedString("RECENTLY SEARCHED", comment: "")))
        }

        let assetManager = AssetManager.shared

        items += userSession.recentlySearched.flatMap { searchable -> FormItem in
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

        return items
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
