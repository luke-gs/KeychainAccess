//
//  EntityEventsViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class EntityEventsViewModel: EntityDetailFilterableFormViewModel {
    
    open var events: [Event] {
        return entity?.events ?? []
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        let events = filteredEvents
        
        builder.title = title
        builder.forceLinearLayout = true
        
        if !events.isEmpty {
            builder += HeaderFormItem(text: header())
            for event in events {
                builder += DetailFormItem(title: event.eventType, subtitle: formattedSubtitle(for: event), detail: event.eventDescription?.ifNotEmpty())
                    .selectionStyle(.fade)
                    .highlightStyle(.fade)
                    .accessory(ItemAccessory(style: .disclosure))
                    .onSelection({ [weak self] _ in
                        if let source = event.source {
                            let detailVC = EventDetailViewController(source: source, eventId: event.id)
                            self?.delegate?.presentPushedViewController(detailVC, animated: true)
                        }
                    })
            }
        }
        
        delegate?.updateLoadingState(filteredEvents.isEmpty ? .noContent : .loaded)
    }
    
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
                name = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            return String(format: NSLocalizedString("This %@ has no related events", bundle: .mpolKit, comment: ""), name)
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
    
    // MARK: - Filtering
    
    var filterTypes: Set<String>?
    var filterDateRange: FilterDateRange?
    var sorting: DateSorting = .newest
    
    open var filteredEvents: [Event] {
        var filtered = self.events
        var filters: [FilterDescriptor<Event>] = []
        
        if let types = filterTypes {
            filters.append(FilterValueDescriptor<Event, String>(key: { $0.eventType }, values: types))
        }
        
        if let dateRange = filterDateRange {
            filters.append(FilterRangeDescriptor<Event, Date>(key: { $0.occurredDate }, start: dateRange.startDate, end: dateRange.endDate))
        }
        
        let dateSort = SortDescriptor<Event>(ascending: sorting == .oldest) { $0.occurredDate }
        
        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: [dateSort])
        
        return filtered
    }
    
    open override var filterApplied: Bool {
        return filterTypes != nil || filterDateRange != nil || sorting != .newest
    }
    
    open override var filterOptions: [FilterOption] {
        // Extract and sort all event types from events
        let types = Set(events.flatMap({ $0.eventType }))
        let sortedTypes = types.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        
        // Calculate indexes of currently selected types
        var selectedIndexes: IndexSet
        if let filterTypes = self.filterTypes {
            if filterTypes.isEmpty == false {
                selectedIndexes = sortedTypes.indexes(where: { filterTypes.contains($0) })
            } else {
                selectedIndexes = IndexSet()
            }
        } else {
            selectedIndexes = IndexSet(integersIn: 0..<types.count)
        }
        
        let typesFilter = FilterList(title: NSLocalizedString("Events Types", comment: ""), displayStyle: .detailList, options: sortedTypes, selectedIndexes: selectedIndexes, allowsNoSelection: true, allowsMultipleSelection: true)
        
        let dateRangeFilter = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: "Sort By", displayStyle: .list, options: DateSorting.allCases, selectedIndexes: [DateSorting.allCases.index(of: self.sorting) ?? 0])
        
        return [typesFilter, dateRangeFilter, sorting]
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
                        filterTypes = []
                    } else {
                        filterTypes = Set(filterList.options[selectedIndexes] as! [String])
                    }
                } else {
                    filterTypes = nil
                }
            case let dateRange as FilterDateRange:
                if dateRange.startDate == nil && dateRange.endDate == nil {
                    filterDateRange = nil
                } else {
                    filterDateRange = dateRange
                }
            case let filterList as FilterList where filterList.options.first is DateSorting:
                guard let selectedIndex = filterList.selectedIndexes.first else {
                    sorting = .newest
                    return
                }
                sorting = filterList.options[selectedIndex] as! DateSorting
            default:
                break
            }
        }
        
        delegate?.updateBarButtonItems()
        delegate?.reloadData()
    }
    
    // MARK: - Internal
    
    public func header() -> String? {
        let count = filteredEvents.count
        
        // TODO: Get from stringsDict
        let base = count != 1 ? NSLocalizedString("%d EVENTS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d EVENT", bundle: .mpolKit, comment: "")
        return String(format: base, count)
    }
    
    private func formattedSubtitle(for event: Event) -> String {
        if let date = event.occurredDate {
            let subtitle = DateFormatter.mediumNumericDate.string(from: date)
            return "Occurred on \(subtitle)"
        } else {
            return "Occurred date unknown"
        }
    }
}
