//
//  EntitySummaryActionListViewModel.swift
//  MPOLKit
//
//  Created by KGWH78 on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Default implementation of the action list view model. The app to supply displayableForEntity which should
/// returns a summary displayable for each type of entity.
public class EntitySummaryActionListViewModel: ActionListViewModelable {

    public weak var actionListViewController: UIViewController?

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public init(summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }

    public func formItems(forEntitiesInCache cache: EntityBucket, in traitCollection: UITraitCollection) -> [FormItem] {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let items = cache.entities.flatMap({ entity -> BaseFormItem? in
            guard let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }
            return summary.summaryFormItem(isCompact: isCompact).onSelection({ [weak self] _ in
                guard let presentable = self?.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                self?.actionListViewController?.present(presentable)
            })
        })

        let numberOfEntities = items.count
        let headerText = "\(numberOfEntities) \(numberOfEntities == 1 ? "ENTITY" : "ENTITIES")"

        return [HeaderFormItem(text: headerText).actionButton(title: "CLEAR", handler: {
            cache.removeAll()
        })] + items
    }

}
