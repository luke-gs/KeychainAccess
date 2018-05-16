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

        if !trafficHistory.isEmpty {

            builder += HeaderFormItem(text: NSLocalizedString("Overview", comment: ""), style: .collapsible)

            if viewController.isCompact() {

                builder += SubtitleFormItem(title: "CRAP".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), subtitle: "Crap".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), image: nil, style: .value)
                builder += SubtitleFormItem(title: "CRAP".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), subtitle: "Crap".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), image: nil, style: .value)
                builder += SubtitleFormItem(title: "CRAP".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), subtitle: "Crap".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), image: nil, style: .value)
                builder += SubtitleFormItem(title: "CRAP".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), subtitle: "Crap".sizing(withNumberOfLines: 0, font: UIFont.preferredFont(forTextStyle: .body)), image: nil, style: .value)
             
            } else {
                builder += TrafficHistoryOverviewFormItem(text: nil, items: [
                    TrafficHistoryCollectionViewCell.Item(number: "1", title: "Demerit Points"),
                    TrafficHistoryCollectionViewCell.Item(number: "2", title: "Demerit Points"),
                    TrafficHistoryCollectionViewCell.Item(number: "3", title: "Demerit Points"),
                    TrafficHistoryCollectionViewCell.Item(number: "4", title: "Demerit Points"),
                    TrafficHistoryCollectionViewCell.Item(number: "5", title: "Demerit Points"),
                    ])
            }



            builder += HeaderFormItem(text: headerTitle, style: .collapsible)
            for trafficHistory in filteredTrafficHistory {
                builder += TrafficHistoryDisplay(trafficHistory).formItem()
            }
        }

        delegate?.updateLoadingState(filteredTrafficHistory.isEmpty ? .noContent : .loaded)
    }

    // MARK: - Filtering & Sorting

    private var filterEventTypes: Set<String>?

    private var filterTypeOptions: Set<String> {
        return Set(trafficHistory.compactMap { $0.name } )
    }

    private var filterDateRange: FilterDateRange?

    private var dateSorting: DateSorting = .newest
    var sortingOptions: [DateSorting] = [.newest, .oldest]

    open var filteredTrafficHistory: [TrafficHistory] {
        var filtered = self.trafficHistory
//        var filters: [FilterDescriptor<Order>] = []
//
//        if let filterTypes = filterEventTypes {
//            filters.append(FilterValueDescriptor<Order, String>(key: { $0.type }, values: filterTypes))
//        }
//
//        if let dateRange = filterDateRange {
//            filters.append(FilterRangeDescriptor<Order, Date>(key: { $0.issuedDate }, start: dateRange.startDate, end: dateRange.endDate))
//        }
//
//        filtered = filtered.filter(using: filters)
//        filtered = filtered.sorted(using: self.sorts)

        return filtered
    }

    open override func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {

    }

    open var sorts: [SortDescriptor<TrafficHistory>] {
        return [SortDescriptor<TrafficHistory>(ascending: dateSorting == .oldest) { $0.issuedDate }]
    }

    open override var isFilterApplied: Bool {
        return filterEventTypes != nil || filterDateRange != nil || dateSorting != .newest
    }

    open override var filterOptions: [FilterOption] {

        let filterList = FilterList(title: String(format: NSLocalizedString("%@ Types", comment: ""), title!),
                                    displayStyle: .detailList,
                                    options: allTypes,
                                    selectedIndexes: selectedTypesIndexes,
                                    allowsNoSelection: true,
                                    allowsMultipleSelection: true)

        let dateRange = FilterDateRange(title: NSLocalizedString("Date Range", comment: ""),
                                        startDate: filterDateRange?.startDate,
                                        endDate: filterDateRange?.endDate,
                                        requiresStartDate: false,
                                        requiresEndDate: false)

        let sortingList = FilterList(title: NSLocalizedString("Date Range", comment: ""), displayStyle: .list,
                                     options: sortingOptions,
                                     selectedIndexes: [sortingOptions.index(of: dateSorting) ?? 0])

        return [filterList, dateRange, sortingList]

    }

    var allTypes: [String] {
        return filterTypeOptions.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    var selectedTypesIndexes: IndexSet {
        var selectedIndexes: IndexSet

        if let filterTypes = filterEventTypes {
            if filterTypes.isEmpty == false {
                selectedIndexes = allTypes.indexes(where: { filterTypes.contains($0) })
            } else {
                selectedIndexes = IndexSet()
            }
        } else {
            selectedIndexes = IndexSet(integersIn: 0..<filterTypeOptions.count)
        }

        return selectedIndexes
    }

    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)

        guard applyingChanges else { return }

        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is String:
                let selectedIndexes = filterList.selectedIndexes
                let indexCount = selectedIndexes.count
                if indexCount != filterList.options.count {
                    if indexCount == 0 {
                        filterEventTypes = []
                    } else {
                        filterEventTypes = Set(filterList.options[selectedIndexes] as! [String])
                    }
                } else {
                    filterEventTypes = nil
                }
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
        return String.localizedStringWithFormat(NSLocalizedString("%d RECORD(s)", comment: ""), count)
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
