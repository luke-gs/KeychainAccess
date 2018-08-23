//
//  EntitySummaryAlertsSearchResultViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class EntitySummaryAlertsSearchResultViewModel<T: MPOLKitEntity>: EntitySummarySearchResultViewModel<T>, SearchAlertsViewModelable, SearchAlertsDelegate {

    public var alertEntities: [Entity] = []

    // Used to sort the entities according to their associated alert level
    private let associatedAlertLevelSort = SortDescriptor<Entity>(ascending: false) { (first, second) -> ComparisonResult in
        let firstAssociatedAlertLevel = first.associatedAlertLevel?.rawValue ?? -1
        let secondAssociatedAlertLevel = second.associatedAlertLevel?.rawValue ?? -1
        if firstAssociatedAlertLevel > secondAssociatedAlertLevel {
            return ComparisonResult.orderedDescending
        } else {
            return ComparisonResult.orderedAscending
        }
    }

    // Used to sort the entities according to their own alert level
    private let entityAlertLevelSort = SortDescriptor<Entity>(ascending: false) { (first, second) -> ComparisonResult in
        let firstAlertLevel = first.alertLevel?.rawValue ?? -1
        let secondAlertLevel = second.alertLevel?.rawValue ?? -1
        if firstAlertLevel > secondAlertLevel {
            return ComparisonResult.orderedDescending
        } else {
            return ComparisonResult.orderedAscending
        }
    }

    public func didSelectEntity(at index: Int) {
        if let presentable = summaryDisplayFormatter.presentableForEntity(alertEntities[index]) {
            self.delegate?.requestToPresent(presentable)
        }
    }

    override public func summaryItemsForSection(_ section: SearchResultSection) -> [FormItem] {
        // If the source is nil, then the section was created locally. In this case, we know that the only section created locally is the Alerts section.
        if section.source == nil {
            if let sectionEntities = section.entities as? [Entity] {
                alertEntities = sectionEntities.sorted(using: [associatedAlertLevelSort, entityAlertLevelSort])
            }
            let alertsFormItem = AlertsFormItem()
            alertsFormItem.dataSource = self
            alertsFormItem.delegate = self
            return [alertsFormItem]
        } else {
            return super.summaryItemsForSection(section)
        }
    }

    override public func processedResults(from rawResults: [AggregatedResult<T>]) -> [SearchResultSection] {
        let previousResults = self.results
        var processedResults: [SearchResultSection] = rawResults.enumerated().map { (index, rawResult) -> SearchResultSection in
            let entities = summarySearchResultsHandler(rawResult.entities)
            return SearchResultSection(title: titleForResult(rawResult), entities: entities, isExpanded: {
                if let previous = previousResults[ifExists: index] {
                    return rawResult.state != previous.state || previous.isExpanded
                }
                return true
            }(), state: rawResult.state, error: rawResult.error, source: rawResult.request.source)
        }

        var alertEntities = [MPOLKitEntity]()

        let finishedResults = rawResults.filter {$0.state == .finished}
        finishedResults.forEach { (finishedResult) in
            let entities = finishedResult.entities.compactMap {$0 as? Entity}
            let filteredEntities = entities.filter {$0.alertLevel != nil || $0.associatedAlertLevel != nil}
            filteredEntities.forEach({ (entity) in
                alertEntities.append(entity)
            })
        }

        if !alertEntities.isEmpty {
            let alertSection = SearchResultSection(title: "Alerts", entities: alertEntities, isExpanded: true, state: .finished, error: nil)
            processedResults.insert(alertSection, at: 0)
        }

        return processedResults
    }

    override public func headerItemForSection(_ section: SearchResultSection) -> LargeTextHeaderFormItem {
        // If the source is nil, then the section was created locally. In this case, we know that the only section created locally is the Alerts section.
        if section.source == nil {
            return LargeTextHeaderFormItem(text: section.title, separatorColor: .clear)
        } else {
            return super.headerItemForSection(section)
        }
    }

    private func summaryThumbnailFormItem(summary: EntitySummaryDisplayable) -> SummaryThumbnailFormItem {
        return SummaryThumbnailFormItem()
            .style(.thumbnail)
            .category(summary.category)
            .badge(summary.badge)
            .badgeColor(summary.borderColor)
            .image(summary.thumbnail(ofSize: .medium))
            .borderColor(summary.borderColor)
            .imageTintColor(summary.iconColor)
    }
}
