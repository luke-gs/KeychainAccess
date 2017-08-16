//
//  PersonOccurrencesViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonOccurrencesViewModel: EntityEventViewModel {

    // MARK: - Public methods
    
    public func reloadSections(with filterTypes: Set<String>?, filterDateRange: FilterDateRange?, sortedBy sorting: DateSorting) {
        
        var events = entity?.events ?? []
        
        let requiresFiltering = filterTypes != nil || filterDateRange != nil
        if requiresFiltering {
            events = events.filter { event in
                if let filterTypes = filterTypes {
                    guard let type = event.eventType, filterTypes.contains(type) else {
                        return false
                    }
                }
                if let dateFilter = filterDateRange {
                    guard let date = event.occurredDate, dateFilter.contains(date) else {
                        return false
                    }
                }
                return true
            }
        }
        
        let dateSorting = sorting.compare(_:_:)
        events.sort { dateSorting(($0.occurredDate ?? .distantPast), ($1.occurredDate ?? .distantPast)) }
        
        sections = events
        delegate?.updateFilterBarButtonItemActivity()
    }
}
