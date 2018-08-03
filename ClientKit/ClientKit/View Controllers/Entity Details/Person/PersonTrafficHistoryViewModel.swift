//
//  PersonTrafficHistoryViewModel.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class PersonTrafficHistoryViewModel: EntityDetailFilterableFormViewModel {

    private var person: Person? {
        return entity as? Person
    }

    open var trafficHistory: [TrafficHistory] {
        return person?.trafficHistory ?? []
    }

    // MARK: - EntityDetailFormViewModel

    open override var title: String? {
        return NSLocalizedString("Traffic History", comment: "")
    }

    open override var noContentTitle: String? {
        return NSLocalizedString("No Records Found", comment: "")
    }

    open override var noContentSubtitle: String? {
        if trafficHistory.isEmpty {
            return NSLocalizedString("There is no Traffic History information available", comment: "")
        } else {
            return NSLocalizedString("This filter has no matching Traffic History", comment: "")
        }
    }

    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .event)
    }

    open override var sidebarCount: UInt? {
        return UInt(trafficHistory.count)
    }

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        let trafficHistory = self.filteredTrafficHistory

        if !trafficHistory.isEmpty {

            builder += LargeTextHeaderFormItem(text: headerTitle)
                .separatorColor(.clear)
            for trafficHistory in filteredTrafficHistory {
                builder += TrafficHistoryDisplay(trafficHistory).formItem()
            }
        }

        delegate?.updateLoadingState(filteredTrafficHistory.isEmpty ? .noContent : .loaded)
    }

    open var trafficHistoryOverviewItems: [NumericValuesView.Item] {
        let trafficHistoryOverview = TrafficHistoryOverviewDisplay(trafficHistory)

        var items: [NumericValuesView.Item] = []
        TrafficHistoryOverviewItem.allCases.forEach {

            let title = trafficHistoryOverview.title(for: $0)
            let value = trafficHistoryOverview.value(for: $0)
            let itemStyle = trafficHistoryOverview.style(for: value)
            items.append(NumericValuesView.Item(title: title, value: value, style: itemStyle))
        }
        return items
    }

    // MARK: - Filtering & Sorting

    private var filterEventTypes: Set<String>?

    private var filterDateRange: FilterDateRange?

    private var dateSorting: DateSorting = .newest
    var sortingOptions: [DateSorting] = [.newest, .oldest]

    open var filteredTrafficHistory: [TrafficHistory] {
        var filtered = self.trafficHistory
        var filters: [FilterDescriptor<TrafficHistory>] = []

        if let dateRange = filterDateRange {
            filters.append(FilterRangeDescriptor<TrafficHistory, Date>(key: { $0.issuedDate }, start: dateRange.startDate, end: dateRange.endDate))
        }

        filtered = filtered.sorted(using: self.sorts)
        filtered = filtered.filter(using: filters)

        return filtered
    }

    open override func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection, previousTraitCollection: previousTraitCollection)
        delegate?.reloadData()
    }

    open var sorts: [SortDescriptor<TrafficHistory>] {
        return [SortDescriptor<TrafficHistory>(ascending: dateSorting == .oldest) { $0.issuedDate }]
    }

    open override var isFilterApplied: Bool {
        return filterEventTypes != nil || filterDateRange != nil || dateSorting != .newest
    }

    open override var filterOptions: [FilterOption] {

        let dateRange = FilterDateRange(title: NSLocalizedString("Date Range", comment: ""),
                                        startDate: filterDateRange?.startDate,
                                        endDate: filterDateRange?.endDate,
                                        requiresStartDate: false,
                                        requiresEndDate: false)

        let sortingList = FilterList(title: NSLocalizedString("Date Range", comment: ""), displayStyle: .list,
                                     options: sortingOptions,
                                     selectedIndexes: [sortingOptions.index(of: dateSorting) ?? 0])

        return [dateRange, sortingList]

    }

    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)

        guard applyingChanges else { return }

        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is DateSorting:
                guard let selectedIndex = filterList.selectedIndexes.first else {
                    self.dateSorting = .newest
                    return
                }
                self.dateSorting = filterList.options[selectedIndex] as! DateSorting
            case let dateRange as FilterDateRange:
                if dateRange.startDate == nil && dateRange.endDate == nil {
                    self.filterDateRange = nil
                } else {
                    self.filterDateRange = dateRange
                }
            default:
                break
            }
        }

        delegate?.updateBarButtonItems()
        delegate?.reloadData()
    }

    // MARK: - Internal

    private var headerTitle: String {
        let count = filteredTrafficHistory.count
        return String.localizedStringWithFormat(NSLocalizedString("%d record(s)", comment: ""), count)
    }

    private func subtitle(for history: TrafficHistory) -> String? {
        if let date = history.issuedDate {
            return NSLocalizedString("Recorded on ", comment: "") + DateFormatter.preferredDateStyle.string(from: date)
        } else {
            return NSLocalizedString("Recorded date unknown", comment: "")
        }
    }

}

public struct TrafficHistoryDisplay: DetailDisplayable, FormItemable {
    let trafficHistory: TrafficHistory

    public init(_ trafficHistory: TrafficHistory) {
        self.trafficHistory = trafficHistory
    }

    public var title: StringSizing? {
        let title = trafficHistory.name ?? NSLocalizedString("Unknown Record", comment: "")
        return title.sizing(withNumberOfLines: 0)
    }

    public var subtitle: StringSizing? {
        let text: String
        if let date = trafficHistory.issuedDate {
            text = NSLocalizedString("Recorded on ", comment: "") + DateFormatter.preferredDateStyle.string(from: date)
        } else {
            text = NSLocalizedString("Recorded date unknown", comment: "")
        }
        return text.sizing(withNumberOfLines: 0)
    }

    public var detail: StringSizing? {
        let text = trafficHistory.trafficHistoryDescription ?? NSLocalizedString("Unknown Traffic History information", comment: "")
        return text.sizing(withNumberOfLines: 0)
    }
}

public enum TrafficHistoryOverviewItem {
    case demeritPoints
    case licenceSurrendered
    case licenceRefused
    case licenceCancelled

    static var allCases: [TrafficHistoryOverviewItem] {
        return [ .demeritPoints, .licenceSurrendered, .licenceRefused, .licenceCancelled]
    }
}

public struct TrafficHistoryOverviewDisplay {

    let trafficHistory: [TrafficHistory]

    let finalisedDemeritPoints: Int
    let licenceSurrenderedCount: Int
    let licenceCancelledCount: Int

    public init(_ trafficHistory: [TrafficHistory]) {
        self.trafficHistory = trafficHistory

        var finalisedDemeritPoints = 0
        var licenceSurrenderedCount = 0
        var licenceCancelledCount = 0

        for item in trafficHistory {
            if item.isLicenceCancelled {
                licenceCancelledCount += 1
            }
            if item.isLicenceSurrendered {
                licenceSurrenderedCount += 1
            }
            finalisedDemeritPoints += item.demeritPoint
        }

        self.finalisedDemeritPoints = finalisedDemeritPoints
        self.licenceCancelledCount = licenceCancelledCount
        self.licenceSurrenderedCount = licenceSurrenderedCount
    }

    public func value(for item: TrafficHistoryOverviewItem) -> Int {
        switch item {
        case .demeritPoints:
            return finalisedDemeritPoints
        case .licenceSurrendered:
            return licenceSurrenderedCount
        case .licenceCancelled:
            return licenceCancelledCount
        case .licenceRefused:
            return 0
        }
    }

    public func title(for item: TrafficHistoryOverviewItem) -> String {

        switch item {
        case .demeritPoints:
            return NSLocalizedString("Finalised Demerit Points", comment: "")
        case .licenceSurrendered:
            return NSLocalizedString("Times Licence Surrendered", comment: "")
        case .licenceCancelled:
            return NSLocalizedString("Times Licence Cancelled", comment: "")
        case .licenceRefused:
            return NSLocalizedString("Times Licence Refused", comment: "")
        }
    }

    public func style(for value: Int) -> NumericValuesView.Style {
        if value <= 0 {
            return .subtle
        }
        return .normal
    }

}
