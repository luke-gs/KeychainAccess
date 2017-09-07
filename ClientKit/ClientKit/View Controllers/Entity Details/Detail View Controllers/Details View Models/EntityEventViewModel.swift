//
//  EntityEventViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EntityEventViewModel: EntityDetailViewModelable {
    
    public typealias DetailsType = Event
    
    weak public var delegate: EntityDetailViewModelDelegate?
    
    public var entity: Entity? {
        didSet {
            let count = itemsCount()
            delegate?.updateSidebarItemCount(count)
            
            let subtitle = noContentSubtitle()
            delegate?.updateNoContentSubtitle(subtitle)
        }
    }
    
    public var sections: [DetailsType] = [] {
        didSet {
            let count = sections.count
            delegate?.updateSidebarItemCount(UInt(count))
            
            let state: LoadingStateManager.State  = sections.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }
    
    public var allEventTypes: Set<String> {
        var allTypes = Set<String>()
        entity?.events?.forEach {
            if let type = $0.eventType {
                allTypes.insert(type)
            }
        }
        return allTypes
    }

    public var sectionHeader: String? {
        let count = numberOfItems()
        
        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }
    
    public func itemsCount() -> UInt {
        return UInt(entity?.events?.count ?? 0)
    }
    
    public func noContentSubtitle() -> String? {
        var subtitle: String?
        
        if entity?.events?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            subtitle = String(format: NSLocalizedString("This %@ has no events", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            subtitle = NSLocalizedString("This filter has no matching events", comment: "")
        }
        return subtitle
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let event = item(at: indexPath.item)!
        
        let title = event.eventType
        let subtitle = formattedTitle(for: event.occurredDate)
        let detail = event.eventDescription
        
        return CellInfo(title: title, subtitle: subtitle, detail: detail)
    }
    
    public func reloadSections(withFilterDescriptors filters: [FilterDescriptor<Event>]?, sortDescriptors: [SortDescriptor<Event>]?) {
        var events = entity?.events ?? []
        
        if let filters = filters {
            events = events.filter(using: filters)
        }
        
        if let sorts = sortDescriptors {
            events = events.sorted(using: sorts)
        }
        
        sections = events
        delegate?.updateFilterBarButtonItemActivity()
    }
    
    // MARK: - Private methods
    
    private func formattedTitle(for date: Date?) -> String {
        let text: String
        if let date = date {
            text = DateFormatter.mediumNumericDate.string(from: date)
        } else {
            text = "unknown"
        }
        return "Occurred on \(text)"
    }
    
    /// MARK: - CellText Model
    
    public struct CellInfo {
        let title: String?
        let subtitle: String?
        let detail: String?
    }
}
