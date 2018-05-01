//
//  PersonCriminalHistoryViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class PersonCriminalHistoryViewModel: EntityDetailFilterableFormViewModel {
    
    private var person: Person? {
        return entity as? Person
    }
    
    private var criminalHistory: [CriminalHistory] {
        return person?.criminalHistory ?? []
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        let criminalHistory = filteredCriminalHistory
        
        builder.title = title
        builder.forceLinearLayout = true
        
        if !criminalHistory.isEmpty {
            builder += HeaderFormItem(text: header())
            
            for item in criminalHistory {
                builder += SubtitleFormItem()
                    .highlightStyle(.fade)
                    .selectionStyle(.fade)
                    .title(title(for: item))
                    .subtitle(subtitle(for: item))
                    .accessory(ItemAccessory(style: .disclosure))
            }
        }
        
        delegate?.updateLoadingState(criminalHistory.isEmpty ? .noContent : .loaded)
    }
    
    open override var title: String? {
        return NSLocalizedString("Criminal History", comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Criminal History Found", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentSubtitle: String? {
        if criminalHistory.isEmpty {
            let name: String
            if let entity = person {
                name = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                name = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            return String(format: NSLocalizedString("This %@ has no criminal history", bundle: .mpolKit, comment: ""), name)
        } else {
            return NSLocalizedString("This filter has no matching history", comment: "")
        }
    }
    
    open override  var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .list)
    }
    
    open override var sidebarCount: UInt? {
        return UInt(criminalHistory.count)
    }
    
    // MARK: - Filtering
    
    fileprivate var filterDateRange: FilterDateRange?
    fileprivate var sorting: Sorting = .dateNewest
    
    var filteredCriminalHistory: [CriminalHistory] {
        var filtered = self.criminalHistory
        var filters: [FilterDescriptor<CriminalHistory>] = []
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<CriminalHistory, Date>(key: { $0.lastOccurred }, start: dateRange.startDate, end: dateRange.endDate))
        }

        let sort: SortDescriptor<CriminalHistory>
        switch self.sorting {
        case .dateNewest, .dateOldest:
            sort = SortDescriptor<CriminalHistory>(ascending: self.sorting == .dateOldest) { $0.lastOccurred }
        case .title:
            sort = SortDescriptor<CriminalHistory>(ascending: true) { $0.offenceDescription }
        }

        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: [sort])
        
        return filtered
    }
    
    open override var filterApplied: Bool {
        return filterDateRange != nil || sorting != .dateNewest
    }
    
    open override var filterOptions: [FilterOption] {
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: NSLocalizedString("Sort By", comment: ""), displayStyle: .list, options: Sorting.allCases, selectedIndexes: Sorting.allCases.indexes(where: { self.sorting == $0 }))
        
        return [dateRange, sorting]
    }
    
    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        guard applyingChanges else { return }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is Sorting:
                self.sorting = filterList.options[filterList.selectedIndexes].first as? Sorting ?? self.sorting
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
    
    open func header() -> String? {
        let count = criminalHistory.count
        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }
    
    open func title(for item: CriminalHistory) -> String? {
        var offenceCount = ""
        if let count = item.offenceCount {
            offenceCount = "(\(count)) "
        }
        return offenceCount + (item.offenceDescription?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", bundle: .mpolKit, comment: ""))
    }
    
    open func subtitle(for item: CriminalHistory) -> String? {
        let lastOccurred: String
        if let date = item.lastOccurred {
            lastOccurred = DateFormatter.preferredDateStyle.string(from: date)
        } else {
            lastOccurred = NSLocalizedString("Unknown", bundle: .mpolKit, comment: "Unknown date")
        }
        return String(format: NSLocalizedString("Last occurred: %@", bundle: .mpolKit, comment: ""), lastOccurred)
    }
    
    // MARK: - Sorting
    // TODO: Refactor
    
    public enum Sorting: Pickable {
        case dateNewest
        case dateOldest
        case title
        
        func compare(_ h1: CriminalHistory, _ h2: CriminalHistory) -> Bool {
            switch self {
            case .dateNewest:
                return DateSorting.newest.compare(h1.lastOccurred ?? .distantPast, h2.lastOccurred ?? .distantPast)
            case .dateOldest:
                return DateSorting.oldest.compare(h1.lastOccurred ?? .distantPast, h2.lastOccurred ?? .distantPast)
            case .title:
                if let h2Title = h2.offenceDescription {
                    return h1.offenceDescription?.localizedStandardCompare(h2Title) == .orderedAscending
                }
                return h1.offenceDescription != nil
            }
        }
        
        public var title: String? {
            switch self {
            case .dateNewest: return NSLocalizedString("Newest", comment: "")
            case .dateOldest: return NSLocalizedString("Oldest", comment: "")
            case .title: return NSLocalizedString("Title", comment: "")
            }
        }
        
        public var subtitle: String? {
            return nil
        }
        
        static let allCases: [Sorting] = [.dateNewest, .dateOldest, .title]
    }
}
