//
//  EntityAlertsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 15/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EntityAlertsViewModel: EntityDetailsViewModelable {
    
    public typealias DetailsType  = [Alert]
    
    public weak var delegate: EntityDetailsViewModelDelegate?

    public var entity: Entity? {
        didSet {
            let count = entity?.alerts?.count ?? 0
            delegate?.updateSidebarItemCount(UInt(count))
            
            let color = entity?.alertLevel?.color
            delegate?.updateSidebarAlertColor(color)
            
            let subtitle = self.noContentSubtitle()
            delegate?.updateNoContentSubtitle(subtitle)
        }
    }
    
    
    public var sections: [DetailsType] = [] {
        didSet {
            let state: LoadingStateManager.State = sections.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }
    
    private var statusDotCache: [Alert.Level: UIImage] = [:]
    
    lazy private var collapsedSections: [String: Set<Alert.Level>] = [:]
    
    
    // MARK: - Public methods
    
    public func reloadSections(with filteredAlertLevels: Set<Alert.Level>, filterDateRange: FilterDateRange?, sortedBy sorting: DateSorting) {
        var alerts = entity?.alerts ?? []
        
        let dateSorting = sorting.compare(_:_:)
        
        func sortingRule(_ alert1: Alert, alert2: Alert) -> Bool {
            let alert1Level = alert1.level?.rawValue ?? 0
            let alert2Level = alert2.level?.rawValue ?? 0
            
            if alert1Level > alert2Level { return true }
            if alert2Level > alert1Level { return false }
            
            return dateSorting((alert1.effectiveDate ?? Date.distantPast), (alert2.effectiveDate ?? Date.distantPast))
        }
        
        let selectAlertLevels = filteredAlertLevels != Set(Alert.Level.allCases)
        let requiresFiltering: Bool = selectAlertLevels || filterDateRange != nil
        
        if requiresFiltering {
            alerts = alerts.filter( { alert in
                if selectAlertLevels {
                    guard let alertLevel = alert.level, filteredAlertLevels.contains(alertLevel) else {
                        return false
                    }
                }
                if let filteredDateRange = filterDateRange {
                    guard let date = alert.effectiveDate, filteredDateRange.contains(date) else {
                        return false
                    }
                }
                return true
            }).sorted(by: sortingRule)
        } else {
            alerts.sort(by: sortingRule)
        }
        
        if alerts.isEmpty {
            self.sections = []
            return
        }
        
        var sections: [[Alert]] = []
        
        while let firstAlertLevel = alerts.first?.level {
            if let firstDifferentIndex = alerts.index(where: { $0.level != firstAlertLevel }) {
                let alertLevelSlice = alerts.prefix(upTo: firstDifferentIndex)
                alerts.removeFirst(firstDifferentIndex)
                sections.append(Array(alertLevelSlice))
            } else {
                sections.append(alerts)
                alerts.removeAll()
            }
        }
        
        self.sections = sections
        
        delegate?.updateFilterBarButtonItemActivity()
    }
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        guard let alerts = item(at: section) else { return 0 }
        
        let level = alerts.first!.level!
        if collapsedSections[entity!.id]?.contains(level) ?? false {
            // Don't assume there is a collapsed sections here because we should load it lazily.
            return 0
        } else {
            return alerts.count
        }
    }
    
    public func numberOfAlerts(for section: Int) -> Int {
        return sections[ifExists: section]?.count ?? 0
    }
    
    public func alert(at indexPath: IndexPath) -> Alert? {
        return sections[indexPath.section][indexPath.item]
    }
    
    public func alerts(for section: Int) -> [Alert]? {
        return item(at: section)
    }
    
    public func headerText(for alerts: [Alert]) -> String? {
        let alertCount = alerts.count
        let level      = alerts.first!.level!
        
        if alertCount > 0, let levelDescription = level.localizedDescription() {
            return "\(alertCount) \(levelDescription.localizedUppercase) "
        }
        return nil
    }
    
    public func updateCollapsedSections(for alerts: [Alert]) {
        let personId = self.entity!.id
        let level    = alerts.first!.level!
        
        var collapsedSections = self.collapsedSections[personId] ?? []
        if collapsedSections.remove(level) == nil {
            // This section wasn't in there and didn't remove
            collapsedSections.insert(level)
        }
        self.collapsedSections[personId] = collapsedSections
    }
    
    public func isExpanded(for alerts: [Alert]) -> Bool {
        let level    = alerts.first!.level!
        let personId = self.entity!.id
        
        return !(collapsedSections[personId]?.contains(level) ?? false)
    }
    
    public func noContentSubtitle() -> String? {
        var subtitle: String?
        
        if entity?.alerts?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            subtitle = String(format: NSLocalizedString("This %@ has no alerts", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            subtitle = NSLocalizedString("This filter has no matching alerts", comment: "")
        }
        
        return subtitle
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let cellImage: UIImage?
        let subtitle : String?
        
        let alert  = self.alert(at: indexPath)!
        let title  = alert.title
        let detail = alert.details ?? "No Description"
        
        if let alertLevel = alert.level {
            if let cachedImage = statusDotCache[alertLevel] {
                cellImage = cachedImage
            } else {
                let image = UIImage.statusDot(withColor: alertLevel.color!)
                statusDotCache[alertLevel] = image
                cellImage = image
            }
        } else  {
            cellImage = nil
        }
        
        if let date = alert.effectiveDate {
            subtitle = NSLocalizedString("Effective from ", bundle: .mpolKit, comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            subtitle = NSLocalizedString("Effective date unknown", bundle: .mpolKit, comment: "")
        }
        
        return CellInfo(image: cellImage, title: title, subtitle: subtitle, detail: detail)
    }
    
    // MARK - Cell Info Struct 
    
    public struct CellInfo {
        let image   : UIImage?
        let title   : String?
        let subtitle: String?
        let detail  : String?
    }
    
}
