//
//  EntitySummaryAlertsSearchResultViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

import AVFoundation

public class EntitySummaryAlertsSearchResultViewModel<T: MPOLKitEntity>: EntitySummarySearchResultViewModel<T>, SearchAlertsViewModelable, SearchAlertsDelegate {

    public var alertEntities: [Entity] = []

    private(set) var shouldDisplayAlerts: Bool
    private(set) var shouldReadAlerts: Bool

    public init(title: String, aggregatedSearch: AggregatedSearch<T>, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default, shouldDisplayAlerts: Bool = true, shouldReadAlerts: Bool = false) {
        self.shouldDisplayAlerts = shouldDisplayAlerts
        self.shouldReadAlerts = shouldReadAlerts
        super.init(title: title, aggregatedSearch: aggregatedSearch, summaryDisplayFormatter: summaryDisplayFormatter)
    }

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

        if shouldDisplayAlerts || shouldReadAlerts {
            var alertEntities = [MPOLKitEntity]()

            // Determine whether the search is complete by iterating over the results and checking if any are still searching.
            let searchComplete = rawResults.reduce(true) { (result, rawResult) -> Bool in
                result && (rawResult.state != SearchState.searching)
            }

            let finishedResults = rawResults.filter {$0.state == .finished}
            finishedResults.forEach { (finishedResult) in
                let entities = finishedResult.entities.compactMap {$0 as? Entity}
                let filteredEntities = entities.filter {$0.alertLevel != nil || $0.associatedAlertLevel != nil}
                filteredEntities.forEach({ (entity) in
                    alertEntities.append(entity)
                })
            }

            if searchComplete && self.shouldReadAlerts {
                if alertEntities.isEmpty {
                    TextToSpeechHelper.default.speak("No Results Found")
                } else {
                    let entity = alertEntities.first!
                    switch entity {
                    case is Vehicle:
                        let summary = VehicleSummaryDisplayable(entity)

                        let rego = (entity as! Vehicle).registration ?? ""

                        let regoFormatted: String = rego.reduce("") { (result, character) -> String in
                            return result + String(character) + " "
                        }

                        var text: String = ""

                        var status: String? = nil
                        if let alert = (entity as! Vehicle).alertLevel {
                            switch alert {
                            case .high:
                                status = "High Alert"
                            case .medium:
                                status = "Medium Alert"
                            case .low:
                                status = "Low Alert"
                            }
                        }

                        if let category = summary.category {
                            let categoryWithSpaces = category.reduce("") { (result, character) -> String in
                                return result + String(character) + " "
                            }
                            text += "Result from \(categoryWithSpaces.trimmingCharacters(in: .whitespaces)). "
                        }

                        if let status = status {
                            text += "\(status). "
                        }
                        if !regoFormatted.isEmpty {
                            text += "Registration: \(regoFormatted.trimmingCharacters(in: .whitespaces)). "
                        }
                        if let color = (entity as! Vehicle).primaryColor {
                            text += "\(color). "
                        }
                        if let makeModelSummary = summary.detail1 {
                            text += "\(makeModelSummary). "
                        }
                        if alertEntities.count > 1 {
                            text += "Multiple Matches Found. "
                        }
                        if !text.isEmpty {
                            TextToSpeechHelper.default.speak(text.trimmingCharacters(in: .whitespaces))
                        }
                    default:
                        fatalError("Text to speech alerts not supported for supplied entity")
                    }
                }
            }

            if !alertEntities.isEmpty && shouldDisplayAlerts {
                let alertSection = SearchResultSection(title: "Alerts", entities: alertEntities, isExpanded: true, state: .finished, error: nil)
                processedResults.insert(alertSection, at: 0)
            }
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
