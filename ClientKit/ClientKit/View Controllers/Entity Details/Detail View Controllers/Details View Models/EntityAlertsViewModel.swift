//
//  EntityAlertsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 15/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EntityAlertsViewModel: EntityDetailViewModelable {

    public typealias DetailsType  = [Alert]

    public weak var delegate: EntityDetailViewModelDelegate?

    public var entity: Entity? {
        didSet {
            let count = entity?.alerts?.count ?? 0
            delegate?.updateSidebarItemCount(UInt(count))
            
            let color = entity?.alertLevel?.color
            
            if let level = entity?.alertLevel, level == .low && entity?.alerts?.count == 0 {
                print("The BE is returning .low values for `alertLevel` when there are no alerts. See https://gridstone.atlassian.net/browse/MPOLA-873 for more info.")
            }
            delegate?.updateSidebarAlertColor(color)
            delegate?.updateNoContentDetails(title: noContentTitle(), subtitle: noContentSubtitle())
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

    public lazy var collapsedSections: Set<Int> = []

    private var expandedItems: Set<IndexPath> = []
    
    // MARK: - Public methods

    public func reloadSections(withFilterDescriptors filters: [FilterDescriptor<Alert>]?, sortDescriptors: [SortDescriptor<Alert>]?) {
        delegate?.updateFilterBarButtonItemActivity()
        delegate?.updateNoContentDetails(title: noContentTitle(), subtitle: noContentSubtitle())
        
        guard var alerts = self.entity?.alerts else {
            self.sections = []
            return
        }
        
        // Filter
        if let filters = filters {
            alerts = alerts.filter(using: filters)
        }
        
        // Sort
        if let sorts = sortDescriptors {
            alerts = alerts.sorted(using: sorts)
        }
        
        // Group alerts by alert level
        var map: [Alert.Level: [Alert]] = [:]
        alerts.forEach { alert in
            guard let level = alert.level else { return }
            if map[level] != nil {
                map[level]!.append(alert)
            } else {
                map[level] = [alert]
            }
        }
        
        let sectionSort = SortDescriptor<Array<Alert>>(ascending: false) { $0.first?.level?.rawValue }
        self.sections = Array(map.values).sorted(using: [sectionSort])
    }

    public func numberOfSections() -> Int {
        return sections.count
    }

    public func numberOfItems(for section: Int) -> Int {
        guard let alerts = item(at: section) else { return 0 }

        let level = alerts.first!.level!

        if collapsedSections.contains(level.rawValue) {
            return 0
        }

        return alerts.count
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
    
    public func noContentTitle() -> String? {
        return NSLocalizedString("No Alerts Found", bundle: .mpolKit, comment: "")
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

    public func updateExpandedForItem(at indexPath: IndexPath) {
        if let itemIndex = expandedItems.index(of: indexPath) {
            expandedItems.remove(at: itemIndex)
        } else {
            expandedItems.insert(indexPath)
        }
    }

    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let cellImage: UIImage?
        let subtitle: String?

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
        } else {
            cellImage = nil
        }

        if let date = alert.effectiveDate {
            subtitle = NSLocalizedString("Effective from ", bundle: .mpolKit, comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            subtitle = NSLocalizedString("Effective date unknown", bundle: .mpolKit, comment: "")
        }

        return CellInfo(image: cellImage, title: title, subtitle: subtitle, detail: detail, expanded: expandedItems.contains(indexPath))
    }

    // MARK - Cell Info Struct

    public struct CellInfo {
        let image: UIImage?
        let title: String?
        let subtitle: String?
        let detail: String?
        let expanded: Bool
    }

}
