//
//  EntitySummaryDisplayable.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol EntitySummaryDisplayable {

    init(_ entity: MPOLKitEntity)
    
    var category: String? { get }
    
    var title: String? { get }
    
    var detail1: String? { get }
    
    var detail2: String? { get }
    
    var borderColor: UIColor? { get }

    var iconColor: UIColor? { get }
    
    var badge: UInt { get }

    func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable?
}

public protocol EntitySummaryDecoratable {
    
    func decorate(with entitySummary: EntitySummaryDisplayable)
    
}

extension EntitySummaryDisplayable {


    /// Configures and returns a SummaryThumbnailFormItem if `isCompact` is `false`.
    /// Otherwise returns SummaryListFormItem.
    ///
    /// - Parameter isCompact: Indicates the style of the form item.
    /// - Returns: A BaseFormItem
    public func summaryFormItem(isCompact: Bool) -> BaseFormItem {
        return isCompact ? summaryListFormItem() : summaryThumbnailFormItem(with: .hero)
    }


    /// Configures and returns a SummaryThubmnailFormItem
    ///
    /// - Parameter style: The style to display.
    /// - Returns: A preconfigured SummaryThumbnailFormItem.
    public func summaryThumbnailFormItem(with style: EntityCollectionViewCell.Style) -> SummaryThumbnailFormItem {
        return SummaryThumbnailFormItem()
            .style(style)
            .category(category)
            .title(title)
            .subtitle(detail1)
            .detail(detail2)
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: style == .hero ? .large : .medium))
            .borderColor(borderColor)
    }


    /// Configures and returns a SummaryListFormItem
    ///
    /// - Returns: A preconfigured SummaryListFormItem.
    public func summaryListFormItem() -> SummaryListFormItem {
        let subtitle = [detail1, detail2].flatMap({$0}).joined(separator: UIConstants.dividerSeparator)
        return SummaryListFormItem()
            .category(category)
            .title(title)
            .subtitle(subtitle)
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: .small))
            .borderColor(borderColor)
            .accessory(ItemAccessory.disclosure)
    }

}
