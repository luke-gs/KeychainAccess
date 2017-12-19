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

    public let displayableForEntity: (MPOLKitEntity) -> (displayable: EntitySummaryDisplayable, presentable: Presentable)?

    public init(displayableForEntity: @escaping (MPOLKitEntity) -> (displayable: EntitySummaryDisplayable, presentable: Presentable)?) {
        self.displayableForEntity = displayableForEntity
    }

    public func formItems(forEntitiesInCache cache: EntityBucket, in traitCollection: UITraitCollection) -> [FormItem] {
        let summaryDisplayable = displayableForEntity

        let isCompact = traitCollection.horizontalSizeClass == .compact
        let items = cache.entities.flatMap({ entity -> BaseFormItem? in
            guard let summary = summaryDisplayable(entity) else { return nil }

            return summary.displayable.summaryFormItem(isCompact: isCompact).onSelection({ [weak self] _ in
                self?.actionListViewController?.present(summary.presentable)
            })
        })

        let numberOfEntities = items.count
        let headerText = "\(numberOfEntities) \(numberOfEntities == 1 ? "ENTITY" : "ENTITIES")"

        return [HeaderFormItem(text: headerText).actionButton(title: "CLEAR", handler: { _ in
            cache.removeAll()
        })] + items
    }

}
