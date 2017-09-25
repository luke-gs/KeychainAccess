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
    
    public typealias DetailsType = EventInfo
    
    weak public var delegate: EntityDetailViewModelDelegate?
    
    public var entity: Entity? {
        didSet {
            let count = sections.first?.events.count ?? 0
            delegate?.updateSidebarItemCount(UInt(count))
            delegate?.updateNoContentDetails(title: noContentTitle(), subtitle: noContentSubtitle())
        }
    }
    
    public var sections: [DetailsType] = [] {
        didSet {
            let count = sections.first?.events.count ?? 0
            delegate?.updateSidebarItemCount(UInt(count))
            
            let state: LoadingStateManager.State  = sections.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }

    public lazy var collapsedSections: Set<Int> = []

    public func numberOfItems(for section: Int = 0) -> Int {
        if collapsedSections.contains(section) {
            return 0
        }
        return sections[section].events.count
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

    public struct EventInfo {
        var type: SectionType
        var events: [Event]
    }

    public enum SectionType {
        case event
    }

    public func header(for section: Int) -> String? {
        let section = item(at: section)!
        let count = section.events.count

        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d EVENTS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d EVENT", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }

    public func itemsCount() -> UInt {
        return UInt(entity?.events?.count ?? 0)
    }
    
    func noContentTitle() -> String {
        return NSLocalizedString("No Events Found", bundle: .mpolKit, comment: "")
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
        let event = item(at: indexPath.section)?.events[indexPath.item]


        let title = event?.eventType
        let subtitle = formattedTitle(for: event?.occurredDate)
        let detail = event?.eventDescription
        
        return CellInfo(title: title, subtitle: subtitle, detail: detail)
    }
    
    public func reloadSections(withFilterDescriptors filters: [FilterDescriptor<Event>]?, sortDescriptors: [SortDescriptor<Event>]?) {
        if var events = entity?.events, !events.isEmpty {
            if let filters = filters {
                events = events.filter(using: filters)
            }

            if let sorts = sortDescriptors {
                events = events.sorted(using: sorts)
            }

            sections = [EventInfo(type: .event, events: events)]
            delegate?.updateFilterBarButtonItemActivity()
        } else {
            sections = []
        }
        delegate?.updateNoContentDetails(title: noContentTitle(), subtitle: noContentSubtitle())
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
