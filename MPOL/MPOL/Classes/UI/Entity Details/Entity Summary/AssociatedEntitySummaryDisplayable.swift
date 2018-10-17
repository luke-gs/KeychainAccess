//
//  AssociatedEntitySummaryDisplayable.swift
//  MPOLKit
//
//  
//

import PublicSafetyKit
import DemoAppKit

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
    
    public func associatedSummaryFormItem(style: EntityDisplayStyle) -> BaseFormItem {
        switch style {
            case .list:
                return associatedSummaryListFormItem()
            case .grid:
                return associatedSummaryFormItem(with: .detail)
        }
    }
    
    public func associatedSummaryListFormItem() -> SummaryListFormItem {
        return summaryListFormItem()
            .styleIdentifier(DemoAppKitStyler.associationStyle)
            .detail(association)
    }
    
    public func associatedSummaryFormItem(with style: EntityCollectionViewCell.Style) -> SummaryThumbnailFormItem {
        let formItem = summaryThumbnailFormItem(with: style, userInterfaceStyle: ThemeManager.shared.currentInterfaceStyle)
        guard let association = association else { return formItem }
        let associationValue = StringSizing(string: association, font: UIFont.boldSystemFont(ofSize: 11))
        return formItem
            .subdetail(associationValue)
    }
}
