//
//  PersonOrdersViewModel.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class PersonOrdersViewModel: EntityDetailFilterableFormViewModel {

    private var person: Person? {
        return entity as? Person
    }

    open var orders: [Order] {
        return person?.orders ?? []
    }

    // MARK: - EntityDetailFormViewModel

    open override var title: String? {
        return NSLocalizedString("Orders", comment: "")
    }

    open override var noContentTitle: String? {
        return NSLocalizedString("No Orders Found", comment: "")
    }

    open override var noContentSubtitle: String? {
        if orders.isEmpty {
            let name: String
            if let entity = entity {
                name = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                name = NSLocalizedString("entity", comment: "")
            }

            return String(format: NSLocalizedString("This %@ has no orders", comment: ""), name)
        } else {
            return NSLocalizedString("This filter has no matching orders", comment: "")
        }
    }

    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .event)
    }

    open override var sidebarCount: UInt? {
        return UInt(orders.count)
    }

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        if !orders.isEmpty {
            builder += HeaderFormItem(text: headerTitle, style: .collapsible)
            for order in filteredOrders {
                builder += DetailFormItem(title: order.type, subtitle: "Subtitle goes here", detail: "Detail goes here")
            }
        }

        delegate?.updateLoadingState(filteredOrders.isEmpty ? .noContent : .loaded)
    }

    // MARK: - Filtering & Sorting

    private var filterEventTypes: Set<String>?

    private var filterTypeOptions: Set<String> {
        return Set(orders.compactMap({ $0.type }))
    }

    private var filterDateRange: FilterDateRange?

    private var dateSorting: DateSorting = .newest
    var sortingOptions: [DateSorting] = [.newest, .oldest]

    open var filteredOrders: [Order] {
        var filtered = self.orders
        var filters: [FilterDescriptor<Order>] = []

        if let filterTypes = filterEventTypes {
            filters.append(FilterValueDescriptor<Order, String>(key: { $0.type }, values: filterTypes))
        }

        if let dateRange = filterDateRange {
            filters.append(FilterRangeDescriptor<Order, Date>(key: { $0.occurredDate }, start: dateRange.startDate, end: dateRange.endDate))
        }

        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: self.sorts)

        return filtered
    }

    open var sorts: [SortDescriptor<Order>] {
        return [SortDescriptor<Order>(ascending: dateSorting == .oldest) { $0.occurredDate }]
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
        let count = filteredOrders.count
        return String.localizedStringWithFormat(NSLocalizedString("%d Order(s)", comment: ""), count)
    }

    private func subtitle(for event: Order) -> String? {
        if let date = event.occurredDate {
            return NSLocalizedString("Recorded on ", comment: "") + DateFormatter.preferredDateStyle.string(from: date)
        } else {
            return NSLocalizedString("Recorded date unknown", comment: "")
        }
    }

}
