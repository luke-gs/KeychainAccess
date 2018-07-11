//
//  AssociatedEntitySummaryDisplayable.swift
//  MPOLKit
//
//  
//

import MPOLKit

public protocol AssociatedEntitySummaryDisplayable: EntitySummaryDisplayable {
    var association: String? { get }
}

public extension Entity {
    public func formattedAssociationReasonsString() -> String? {
        return associatedReasons?.sorted(using: [SortDescriptor<AssociationReason>(ascending: false, key: { $0.effectiveDate })])
            .compactMap({ $0.formattedReason() })
            .joined(separator: ", ")
    }
}

extension AssociatedEntitySummaryDisplayable {
    
    public func associatedSummaryFormItem(isCompact: Bool) -> BaseFormItem {
        return isCompact ? associatedSummaryListFormItem() : associatedSummaryFormItem(with: .detail)
    }
    
    public func associatedSummaryListFormItem() -> SummaryListFormItem {
        return summaryListFormItem()
            .detail(association)
            .detailFont(UIFont.boldSystemFont(ofSize: 11))
            .detailColorKey(.primaryText)
    }
    
    public func associatedSummaryFormItem(with style: EntityCollectionViewCell.Style) -> SummaryThumbnailFormItem {
        let formItem = summaryThumbnailFormItem(with: style)
        guard let association = association else { return formItem }
        let associationValue = StringSizing(string: association, font: UIFont.boldSystemFont(ofSize: 11))
        return formItem
            .subdetail(associationValue)
    }
}
