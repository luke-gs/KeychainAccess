//
//  EntityRetrievedEventsViewModel.swift
//
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class EntityRetrievedEventsViewModel: EntityDetailFilterableFormViewModel {

    open var events: [RetrievedEvent] {

        return entity?.events ?? []
    }

    // MARK: - EntityDetailFormViewModel

    open override var title: String? {
        return NSLocalizedString("Events", comment: "")
    }

    open override var noContentTitle: String? {
        return NSLocalizedString("No Events Found", comment: "")
    }

    open override var noContentSubtitle: String? {
        if events.isEmpty {
            let name: String
            if let entity = entity {
                name = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                name = NSLocalizedString("entity", comment: "")
            }

            return String(format: NSLocalizedString("This %@ has no events", comment: ""), name)
        } else {
            return NSLocalizedString("This filter has no matching events", comment: "")
        }
    }

    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .list)
    }

    open override var sidebarCount: UInt? {
        return UInt(events.count)
    }

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        if !events.isEmpty {
            builder += LargeTextHeaderFormItem(text: headerTitle)
                .separatorColor(.clear)
            for event in filteredEvents {
                builder += DetailFormItem(title: event.type, subtitle: subtitle(for: event), detail: detail(for: event))
                    .accessory(ItemAccessory.disclosure)
                    .onSelection({ [weak self] _ in
                        self?.presentEventSummary(in: viewController, event: event)
                    })
            }
        }

        delegate?.updateLoadingState(filteredEvents.isEmpty ? .noContent : .loaded)
    }

    // MARK: - Filtering & Sorting

    private var filterEventTypes: Set<String>?

    private var filterTypeOptions: Set<String> {
        return Set(events.compactMap { $0.type })
    }

    private var filterDateRange: FilterDateRange?

    private var dateSorting: DateSorting = .newest
    var sortingOptions: [DateSorting] = [.newest, .oldest]

    open var filteredEvents: [RetrievedEvent] {
        var filtered = self.events
        var filters: [FilterDescriptor<RetrievedEvent>] = []

        if let filterTypes = filterEventTypes {
            filters.append(FilterValueDescriptor<RetrievedEvent, String>(key: { $0.type }, values: filterTypes))
        }

        if let dateRange = filterDateRange {
            filters.append(FilterRangeDescriptor<RetrievedEvent, Date>(key: { $0.occurredDate }, start: dateRange.startDate, end: dateRange.endDate))

        }

        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: self.sorts)

        return filtered
    }

    open var sorts: [SortDescriptor<RetrievedEvent>] {
        return [SortDescriptor<RetrievedEvent>(ascending: dateSorting == .oldest) { $0.occurredDate }]
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

    // MARK: - Private

    private var headerTitle: String {
        let count = filteredEvents.count
        return String.localizedStringWithFormat(NSLocalizedString("%d Event(s)", comment: ""), count)
    }

    private func subtitle(for event: RetrievedEvent) -> String? {
        if let date = event.occurredDate {
            let locationString = event.jurisdiction != nil ? " (\(event.jurisdiction!))": ""
            return NSLocalizedString("Recorded on ", comment: "") + DateFormatter.preferredDateStyle.string(from: date) + locationString
        } else {
            return NSLocalizedString("Recorded date unknown", comment: "")
        }
    }

    private func detail(for event: RetrievedEvent) -> StringSizable? {
        let details = event.eventDescription?.ifNotEmpty()
        return details?.sizing(withNumberOfLines: 2)
    }

    private func presentEventSummary(in viewController: UIViewController, event: RetrievedEvent) {
        let viewModel = RetrievedEventSummaryViewModel(event: event)
        let eventVC = RetrievedEventSummaryViewController(viewModel: viewModel)
        eventVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: viewController, action: #selector(UIViewController.dismissAnimated))

        let navController = ModalNavigationController(rootViewController: eventVC)
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: 512, height: 736)

        viewController.pushableSplitViewController?.presentModalViewController(navController, animated: true, completion: nil)
    }

}
