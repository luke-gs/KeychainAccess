//
//  PersonOccurrencesViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonOccurrencesViewModel: PersonDetailsViewModel<Event> {
    
    public var allEventTypes: Set<String> {
        var allTypes = Set<String>()
        person?.events?.forEach {
            if let type = $0.eventType {
                allTypes.insert(type)
            }
        }
        return allTypes
    }
    
    // MARK: - Public methods
    
    public func reloadSections(with filterTypes: Set<String>?, filterDateRange: FilterDateRange?, sortedBy sorting: DateSorting) {
        
        var events = person?.events ?? []
        
        let requiresFiltering = filterTypes != nil || filterDateRange != nil
        if requiresFiltering {
            events = events.filter { event in
                if let filterTypes = filterTypes {
                    guard let type = event.eventType, filterTypes.contains(type) else {
                        return false
                    }
                }
                if let dateFilter = filterDateRange {
                    guard let date = event.date, dateFilter.contains(date) else {
                        return false
                    }
                }
                return true
            }
        }
        
        let dateSorting = sorting.compare(_:_:)
        events.sort { dateSorting(($0.date ?? .distantPast), ($1.date ?? .distantPast)) }
        
        sections = events
        delegate?.updateFilterBarButtonItemActivity()
    }
    
    public override func itemsCount() -> UInt {
        return UInt(person?.events?.count ?? 0)
    }
    
    public override func noContentSubtitle() -> String? {
        var subtitle: String?
        
        if person?.actions?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = person {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            subtitle = String(format: NSLocalizedString("This %@ has no involvements", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            subtitle = NSLocalizedString("This filter has no matching involvements", comment: "")
        }
        return subtitle
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let event = item(at: indexPath.item)!
        
        let title = event.eventType
        let subtitle = formattedTitle(for: nil)
        let detail = event.eventDescription
        
        return CellInfo(title: title, subtitle: subtitle, detail: detail)
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
