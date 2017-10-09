//
//  TasksMapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 4/10/17.
//

import UIKit

public class TasksMapFilterViewModel {
    
    public weak var delegate: TasksMapFilterViewModelDelegate?

    /// Filters for annotations data source
    public struct Filter: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let incidents = Filter(rawValue: 1 << 0)
        public static let patrol    = Filter(rawValue: 1 << 1)
        public static let broadcast = Filter(rawValue: 1 << 2)
        public static let resources = Filter(rawValue: 1 << 3)
        
        /// Array of all filters in the OptionSet
        public static let allFilters: [Filter] = [.incidents, .patrol, .broadcast, .resources]
    }
    
    /// The active map layers
    public private(set) var currentFilter: Filter = [.incidents, .resources]
    
    
    /// Title for the cell at specified index path
    func titleForItem(at indexPath: IndexPath) -> String? {
        // Convert index path to Filter type
        let filter = Filter(rawValue: 1 << indexPath.item)
        
        switch filter {
        case .incidents: return NSLocalizedString("Incidents", comment: "Incidents Map Layer")
        case .patrol: return NSLocalizedString("Patrol", comment: "Patrol Map Layer")
        case .broadcast: return NSLocalizedString("Broadcast", comment: "Broadcast Map Layer")
        case .resources: return NSLocalizedString("Resources", comment: "Resources Map Layer")
        default:
            return nil
        }
    }
    
    /// Whether the filter at the index path is checked
    func isChecked(at indexPath: IndexPath) -> Bool {
        // Check if the current filter has a filter matching the index path
        return currentFilter.contains(Filter(rawValue: 1 << indexPath.item))
    }
    
    
    /// Turns on or off the filter at the index path
    func toggleItem(at indexPath: IndexPath) {
        // Convert index path to Filter type
        let filter = Filter(rawValue: 1 << indexPath.item)
        
        // Add or remove the filter based on whether it exists
        if currentFilter.contains(filter) {
            currentFilter.remove(filter)
        } else {
            currentFilter.insert(filter)
        }
        
        // Inform delegate of the change
        delegate?.filterDidChange(to: currentFilter)
    }
    
    /// Gets the colour of the text to display on the cell
    func textColor(at indexPath: IndexPath) -> UIColor {
        // Get current theme and colours
        let theme = ThemeManager.shared.theme(for: .current)
        let enabled = theme.color(forKey: .primaryText)!
        let disabled = theme.color(forKey: .secondaryText)!
        
        return isChecked(at: indexPath) ? enabled : disabled
    }
    
    /// The number of filters available
    func numberOfFilters() -> Int {
        return Filter.allFilters.count
    }
}

public protocol TasksMapFilterViewModelDelegate: class {
    /// Called when filter did change
    func filterDidChange(to filter: TasksMapFilterViewModel.Filter)
}
