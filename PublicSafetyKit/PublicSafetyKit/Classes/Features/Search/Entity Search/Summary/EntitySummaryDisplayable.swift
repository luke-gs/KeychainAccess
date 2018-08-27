//
//  EntitySummaryDisplayable.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol EntitySummaryDisplayable {

    var category: String? { get }
    
    var title: String? { get }
    
    var detail1: String? { get }
    
    var detail2: String? { get }
    
    var borderColor: UIColor? { get }

    var iconColor: UIColor? { get }
    
    var badge: UInt { get }

    func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable?

    var priority: Int { get }

    init(_ entity: MPOLKitEntity)
}

extension EntitySummaryDisplayable {

    public var priority: Int { return -1 }

}

extension Array where Element == EntitySummaryDisplayable {

    public func highestPriority() -> Element? {
        var selectedElement: Element?

        for element in self {
            if let lastElement = selectedElement {
                if element.priority > lastElement.priority {
                    selectedElement = element
                }
            } else {
                selectedElement = element
            }
        }

        return selectedElement
    }

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
        return isCompact ? summaryListFormItem() : summaryThumbnailFormItem(with: .detail)
    }


    /// Configures and returns a SummaryThubmnailFormItem
    ///
    /// - Parameter style: The style to display.
    /// - Returns: A preconfigured SummaryThumbnailFormItem.
    public func summaryThumbnailFormItem(with style: EntityCollectionViewCell.Style) -> SummaryThumbnailFormItem {
        return SummaryThumbnailFormItem()
            .style(style)
            .width(.column(2))
            .category(category)
            .title(title?.sizing(withNumberOfLines: style == .hero ? 0 : 1))
            .subtitle(detail1?.sizing(withNumberOfLines: style == .hero ? 0 : 1))
            .detail(detail2?.sizing(withNumberOfLines: style == .hero ? 0 : 2))
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: style == .hero ? .large : .medium))
            .borderColor(borderColor)
            .imageTintColor(iconColor)
    }


    /// Configures and returns a SummaryListFormItem
    ///
    /// - Returns: A preconfigured SummaryListFormItem.
    public func summaryListFormItem() -> SummaryListFormItem {
        let subtitle = [detail1, detail2].joined(separator: ThemeConstants.dividerSeparator)
        return SummaryListFormItem()
            .category(category)
            .title(title?.sizing(withNumberOfLines: 0))
            .subtitle(subtitle.sizing(withNumberOfLines: 0))
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: .small))
            .borderColor(borderColor)
            .highlightStyle(.fade)
            .imageTintColor(iconColor)
            .accessory(ItemAccessory.disclosure)
    }

}
