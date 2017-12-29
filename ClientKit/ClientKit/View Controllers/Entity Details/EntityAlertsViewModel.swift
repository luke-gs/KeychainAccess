//
//  EntityAlertsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 15/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class EntityAlertsViewModel {
    
    // MARK: - Properties
    
    open var entity: Entity? {
        didSet {
            let count = alerts.count
            delegate?.updateSidebarItemCount(UInt(count))
            
            let color = entity?.alertLevel?.color
            delegate?.updateSidebarAlertColor(color)
            
            delegate?.updateLoadingState(alerts.isEmpty ? .noContent : .loaded)
            delegate?.reloadData()
        }
    }
    
    open var alerts: [Alert] {
        return entity?.alerts ?? []
    }
    
    open var filteredAlerts: [[Alert]] {
        var filtered = self.alerts
        
        var filters: [FilterDescriptor<Alert>] = [FilterValueDescriptor<Alert, Alert.Level>(key: { $0.level }, values: self.filteredAlertLevels)]
        
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<Alert, Date>(key: { $0.effectiveDate }, start: dateRange.startDate, end: dateRange.endDate))
        }
        
        let sort = SortDescriptor<Alert>(ascending: dateSorting == .oldest) { $0.effectiveDate }
        
        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: [sort])
        
        // Group alerts by alert level
        var map: [Alert.Level: [Alert]] = [:]
        filtered.forEach { alert in
            guard let level = alert.level else { return }
            if map[level] != nil {
                map[level]!.append(alert)
            } else {
                map[level] = [alert]
            }
        }
        
        let sectionSort = SortDescriptor<Array<Alert>>(ascending: false) { $0.first?.level?.rawValue }
        return Array(map.values).sorted(using: [sectionSort])
    }
    
    open weak var delegate: EntityDetailViewModelDelegate?
    
    private var statusDotCache: [Alert.Level: UIImage] = [:]
    private var expandedAlerts: Set<Alert> = []
    
    private var filteredAlertLevels: Set<Alert.Level> = Set(Alert.Level.allCases)
    private var filterDateRange: FilterDateRange?
    private var dateSorting: DateSorting = .newest
    
    // MARK: - Methods
    
    open func construct(builder: FormBuilder) {
        builder.title = NSLocalizedString("Alerts", bundle: .mpolKit, comment: "")
        builder.forceLinearLayout = true
        
        let filteredAlerts = self.filteredAlerts
        
        for alerts in filteredAlerts {
            if !alerts.isEmpty {
                builder += HeaderFormItem(text: header(for: alerts), style: .collapsible)
                for alert in alerts {
                    builder += DetailFormItem()
                        .title(alert.title)
                        .subtitle(subtitle(for: alert))
                        .detail(detail(for: alert))
                        .image(image(for: alert))
                        .highlightStyle(.fade)
                        .selectionStyle(.fade)
                        .onSelection({ [weak self] _ in
                            self?.updateExpanded(for: alert)
                            self?.delegate?.reloadData()
                        })
                }
            }
        }
        
        delegate?.updateLoadingState(filteredAlerts.isEmpty ? .noContent : .loaded)
    }
    
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Alerts Found", bundle: .mpolKit, comment: "")
    }
    
    open func noContentSubtitle() -> String? {
        if entity?.alerts?.isEmpty ?? true {
            let name: String
            if let entity = entity {
                name = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                name = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            return String(format: NSLocalizedString("This %@ has no alerts", bundle: .mpolKit, comment: ""), name)
        } else {
            return NSLocalizedString("This filter has no matching alerts", comment: "")
        }
    }
    
    // MARK: - Filtering
    
    open func isFiltered() -> Bool {
        let isFilteredByAlertLevel = filteredAlertLevels != Set(Alert.Level.allCases)
        return isFilteredByAlertLevel || filterDateRange != nil
    }
    
    open func filterOptions() -> [FilterOption] {
        let alertLevels: [Alert.Level] = Alert.Level.all
        
        let filterLevels = FilterList(title: NSLocalizedString("Alert Types", comment: ""), displayStyle: .checkbox, options: alertLevels, selectedIndexes: alertLevels.indexes(where: { filteredAlertLevels.contains($0) }))
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: "Sort By", displayStyle: .list, options: DateSorting.allCases, selectedIndexes: [DateSorting.allCases.index(of: dateSorting) ?? 0])
        
        return [filterLevels, dateRange, sorting]
    }
    
    public func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        guard applyingChanges else { return }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is Alert.Level:
                self.filteredAlertLevels = Set((filterList.options as! [Alert.Level])[filterList.selectedIndexes])
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
        
        delegate?.updateFilterBarButtonItemActivity()
        delegate?.reloadData()
    }
    
    // MARK: - Internal
    
    private func header(for alerts: [Alert]) -> String? {
        if let level = alerts.first?.level, let levelDescription = level.localizedDescription() {
            return "\(alerts.count) \(levelDescription.localizedUppercase) "
        }
        
        return nil
    }
    
    private func subtitle(for alert: Alert) -> String? {
        if let date = alert.effectiveDate {
            return NSLocalizedString("Effective from ", bundle: .mpolKit, comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            return NSLocalizedString("Effective date unknown", bundle: .mpolKit, comment: "")
        }
    }
    
    private func detail(for alert: Alert) -> StringSizable? {
        let details = alert.details ?? NSLocalizedString("No Description", bundle: .mpolKit, comment: "")
        let numberOfLines = expandedAlerts.contains(alert) ? 0 : 2
        return details.sizing(withNumberOfLines: numberOfLines)
    }
    
    private func image(for alert: Alert) -> UIImage? {
        if let level = alert.level {
            if let cachedImage = statusDotCache[level] {
                return cachedImage
            } else {
                let image = UIImage.statusDot(withColor: level.color!)
                statusDotCache[level] = image
                return image
            }
        }
        
        return nil
    }
    
    private func updateExpanded(for alert: Alert) {
        if expandedAlerts.remove(alert) == nil {
            expandedAlerts.insert(alert)
        }
    }
    
}
