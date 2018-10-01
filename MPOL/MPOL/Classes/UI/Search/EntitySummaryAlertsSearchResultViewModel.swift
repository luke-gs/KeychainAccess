//
//  EntitySummaryAlertsSearchResultViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

import AVFoundation

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
            let shouldBeExpanded: Bool = {
                if let previous = previousResults[ifExists: index] {
                    return rawResult.state != previous.state || previous.isExpanded
                }
                return true
            }()
            return SearchResultSection(title: titleForResult(rawResult), entities: entities, isExpanded: shouldBeExpanded, state: rawResult.state, error: rawResult.error, source: rawResult.request.source)
        }

        var alertEntities = [MPOLKitEntity]()

        if let pscore = rawResults.first, pscore.state == .finished {
            if (pscore.entities.compactMap { $0 as? Vehicle }).count == 1 {
                let firstResult = pscore.entities.first as! Vehicle
                let summary = VehicleSummaryDisplayable(firstResult)

                let rego = firstResult.registration ?? ""
                let crap = rego.map { value -> String in
                    let result = String(value)
                    if let number = Int(result) {
                        return String(number) + " "
                    } else {
                        return result
                    }
                }
                let crap2 = crap.joined()

                let status: String?
                if let alert = firstResult.alertLevel {
                    switch alert {
                    case .high:
                        status = "High alert"
                    case .medium:
                        status = "Medium alert"
                    case .low:
                        status = "Low alert"
                    }
                } else {
                    status = nil
                }


                let text = "One result from \(pscore.request.source.localizedBadgeTitle). \nRegistration: \(crap2), \(status != nil ? "\n\(status!)" : ""), \(summary.detail1 ?? ""), \(summary.detail2 ?? "")"
                VoiceSearchWorkflowManager.shared.speak(text)
            } else if (pscore.entities.compactMap { $0 as? Vehicle }).count == 0 {
                let text = "No results from \(pscore.request.source.localizedBadgeTitle)"
                VoiceSearchWorkflowManager.shared.speak(text)
            }
        }

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
