//
//  DemoAppKitStyler.swift
//  DemoAppKit
//
//  Created by KGWH78 on 19/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PatternKit

public class DemoAppKitStyler: PublicSafetyKitStyler {

    public override func applyThemeToFormItem(_ item: BaseFormItem) {
        super.applyThemeToFormItem(item)

        switch item {
        case let item as IncidentSummaryFormItem:
            guard let cell = item.cell as? TasksListIncidentCollectionViewCell else { return }
            cell.apply(theme: theme)

        case let item as TrafficHistoryOverviewFormItem:
            guard let cell = item.cell as? TrafficHistoryCollectionViewCell else { return }
            cell.apply(theme: theme)
        default: break
        }
    }

    public override class func configureSharedStyles() {
        super.configureSharedStyles()
        let formStyler = Styler.shared
        formStyler.mainStyle = DemoAppKitStyler()

        formStyler.setStyler(ThemedItemStyler<RowDetailFormItem> { item, theme in
            let cell = item.cell as! CollectionViewFormRowDetailCell
            cell.detailLabel.textColor = theme.color(forKey: .redText)
        }, forKey: DemoAppKitStyler.summaryRequiredStyle)

        formStyler.setStyler(ThemedItemStyler<SummaryListFormItem> { item, theme in
            let cell = item.cell as! EntityListCollectionViewCell
            cell.detailLabel.textColor = theme.color(forKey: .primaryText)
        }, forKey: DemoAppKitStyler.associationStyle)

        formStyler.setStyler(ThemedItemStyler<SummaryListFormItem> { item, theme in
            let cell = item.cell as! EntityListCollectionViewCell
            cell.detailLabel.textColor = theme.color(forKey: .redText)
        }, forKey: DemoAppKitStyler.eventEntityStyle)

        formStyler.setStyler(ThemedItemStyler<SubItemFormItem> { item, theme in
            let cell = item.cell as! SubItemCollectionViewCell
            cell.detailLabel.textColor = theme.color(forKey: .redText)
        }, forKey: DemoAppKitStyler.additionalActionStyle)
    }

}

extension DemoAppKitStyler {
    public static let summaryRequiredStyle = "summaryRequiredStyle"
    public static let associationStyle = "associationStyle"
    public static let eventEntityStyle = "eventEntityStyle"
    public static let additionalActionStyle = "additionalActionStyle"

}
