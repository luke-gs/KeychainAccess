//
//  EntitySummaryRecentsViewModel.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Default implementation of recents view model.
open class EntitySummaryRecentsViewModel: SearchRecentsViewModel {
    
    public var customNoContentView: UIView?

    public let recentlyViewed: EntityBucket

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
        self.recentlyViewed = userSession.recentlyViewed
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
        guard (delegate?.traitCollection.horizontalSizeClass ?? .compact) != .compact else { return nil }
        let theme = ThemeManager.shared.theme(for: .dark)
        let attributedTitle = NSMutableAttributedString(string: NSLocalizedString("Recently Viewed", comment: ""))
        if let titleColor = theme.color(forKey: .primaryText) {
            attributedTitle.setAttributes([NSAttributedStringKey.foregroundColor: titleColor], range: NSMakeRange(0, attributedTitle.length))
        }
        
        let largeTextHeader = LargeTextHeaderFormItem(text: attributedTitle)
        largeTextHeader.separatorColor(.clear)
        largeTextHeader.layoutMargins?.top = 0
        largeTextHeader.layoutMargins?.bottom = 0
        return largeTextHeader
    }

    open func summaryItemsForRecentlyViewed() -> [FormItem] {
        let isCompact = (delegate?.traitCollection.horizontalSizeClass ?? .compact) == .compact

        let theme = ThemeManager.shared.theme(for: .dark)
        let primaryColor          = theme.color(forKey: .primaryText)
        let secondaryColor        = theme.color(forKey: .secondaryText)
        let entityBackgroundColor = theme.color(forKey: .entityThumbnailBackground)
        let entityImageTint       = theme.color(forKey: .entityImageTint)

        var recentlyViewed = userSession.recentlyViewed.entities
        let numberOfEntities = recentlyViewed.count
        let maximum = 5

        if numberOfEntities > maximum {
            let lastIndex = numberOfEntities - 1
            recentlyViewed = Array(recentlyViewed[(lastIndex - maximum)...lastIndex])
        }

        return recentlyViewed.reversed().compactMap { entity in
            guard let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }
            let thumbnailTint = summary.iconColor ?? entityImageTint
            return summary.summaryThumbnailFormItem(with: .detail)
                .titleTextColor(!isCompact ? primaryColor : nil)
                .subtitleTextColor(!isCompact ? primaryColor : nil)
                .detailTextColor(!isCompact ? secondaryColor : nil)
                .thumbnailBackgroundColor(!isCompact ? entityBackgroundColor : nil)
                .imageTintColor(!isCompact ? thumbnailTint : summary.iconColor)
                .badge(0)
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
        let largeTextHeader = LargeTextHeaderFormItem(text: NSLocalizedString("Recently Searched", comment: "Title of a list of the last searches the user has made"))
        largeTextHeader.separatorColor(.clear)
        return largeTextHeader
    }

    open func summaryItemsForRecentlySearched() -> [FormItem] {
        // TODO: replace with real time ago value
        let timeAgoAttributedString = NSMutableAttributedString(string: "5 mins ago", attributes: [.font            : UIFont.systemFont(ofSize: 12),
                                                                                                   .foregroundColor : UIColor.gray])
        
        let assetManager = AssetManager.shared

        return userSession.recentlySearched.compactMap { searchable -> FormItem in
            return DetailFormItem()
                .imageStyle(.titleAligned)
                .separatorStyle(.indentedAtTextLeading)
                .title(searchable.text?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "[Recently Searched] - No search term"))
                .subtitle(searchable.type?.ifNotEmpty() ?? NSLocalizedString("(No Search Category)", comment: "[Recently Searched] - No search category"))
                .detail(timeAgoAttributedString)
                .image((searchable.imageKey != nil ? assetManager.image(forKey: searchable.imageKey!) : nil)?.surroundWithCircle(diameter: 50, color: .disabledGray))
                .accessory(RoundedLabelAccessory(text: NSLocalizedString("Search", comment: "[Recently Searched] - Search Accessory")))
                .width(.column(2))
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
