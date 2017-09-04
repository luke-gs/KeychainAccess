//
//  PersonCriminalHistoryViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonCriminalHistoryViewModel: PersonDetailsViewModel<CriminalHistory> {
    
    // MARK: - Public methods
    
    public func reloadSections(with filterDateRange: FilterDateRange?, sortedBy sorting: PersonCriminalHistoryViewController.Sorting) {
        var criminalHistory = person?.criminalHistory ?? []
        if let dateRange = filterDateRange {
            criminalHistory = criminalHistory.filter { history in
                if let date = history.lastOccurred, dateRange.contains(date) {
                    return true
                }
                return false
            }
        }
        
        criminalHistory.sort(by: sorting.compare(_:_:))
        sections = criminalHistory
        
        delegate?.updateFilterBarButtonItemActivity()
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let history = item(at: indexPath.item)!
        
        let titleText    = title(for: history)
        let subtitleText = subtitle(for: history)
        
        return CellInfo(title: titleText, subtitle: subtitleText)
    }
    
    // MARK: - Private methods
    
    public override func itemsCount() -> UInt {
        return UInt(person?.criminalHistory?.count ?? 0)
    }
    
    public override func noContentSubtitle() -> String? {
        var subtitle: String?
        
        if person?.criminalHistory?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = person {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            subtitle = String(format: NSLocalizedString("This %@ has no criminal history", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            subtitle = NSLocalizedString("This filter has no matching history", comment: "")
        }
        
        return subtitle
    }
    
    
    private func title(for history: CriminalHistory) -> String? {
        var offenceCountText = ""
        if let offenceCount = history.offenceCount {
            offenceCountText = "(\(offenceCount)) "
        }
        
        return offenceCountText + (history.offenceDescription?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", bundle: .mpolKit, comment: ""))
    }
    
    private func subtitle(for history: CriminalHistory) -> String? {
        let lastOccurredDateString: String
        if let lastOccurred = history.lastOccurred {
            lastOccurredDateString = DateFormatter.mediumNumericDate.string(from: lastOccurred)
        } else {
            lastOccurredDateString = NSLocalizedString("Unknown", bundle: .mpolKit, comment: "Unknown date")
        }
        return String(format: NSLocalizedString("Last occurred: %@", bundle: .mpolKit, comment: ""), lastOccurredDateString)
    }
    
    /// MARK: - CellText Model

    public struct CellInfo {
        let title: String?
        let subtitle: String?
    }
}
