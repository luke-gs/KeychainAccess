//
//  PersonActionsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonActionsViewModel: PersonDetailsViewModel<Action> {
    
    public var allActionTypes: Set<String> {
        var allTypes = Set<String>()
        person?.actions?.forEach {
            if let type = $0.type {
                allTypes.insert(type)
            }
        }
        return allTypes
    }
    
    /// Filtered sections
    public func reloadSections(with filterTypes: Set<String>?, filterDateRange: FilterDateRange?) {
        var actions = person?.actions ?? []
        
        let selectActionTypes = filterTypes != nil
        let requiresFiltering: Bool = selectActionTypes || filterDateRange != nil
        
        if requiresFiltering {
            actions = actions.filter { action in
                if selectActionTypes {
                    guard let type = action.type, filterTypes!.contains(type) else {
                        return false
                    }
                }
                
                if let filteredDateRange = filterDateRange {
                    guard let date = action.date, filteredDateRange.contains(date) else {
                        return false
                    }
                }
                
                return true
            }
        }
        
        sections = actions
        delegate?.updateFilterBarButtonItemActivity()
    }

    
    // MARK: - Public methods
    
    public override func itemsCount() -> UInt {
        return UInt(person?.actions?.count ?? 0)
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
            
            subtitle = String(format: NSLocalizedString("This %@ has no actions", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            subtitle = NSLocalizedString("This filter has no matching actions", comment: "")
        }
        
        return subtitle
    }
    
    ///A custom section header for the actions
    public override var sectionHeader: String? {
        let count = numberOfItems()
        
        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d ACTIONS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ACTION", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let action = item(at: indexPath.item)!

        let titleText    = title(for: action)
        let subtitleText = subtitle(for: action)

        return CellInfo(title: titleText, subtitle: subtitleText, detail: nil)
    }
    
    // MARK: - Private methods
    
    private func title(for action: Action) -> String? {
        return action.type?.title ?? NSLocalizedString("Action (Unknown Type)", bundle: .mpolKit, comment: "")
    }
    
    private func subtitle(for action: Action) -> String? {
        guard let date = action.date else {
            return NSLocalizedString("Date unknown", bundle: .mpolKit, comment: "")
        }
        
        let text = DateFormatter.shortDate.string(from: date)
        return "Occurred on \(text)"
    }
    
    // MARK: - CellText Model
    
    public struct CellInfo {
        let title   : String?
        let subtitle: String?
        let detail  : String?
    }
    
}
