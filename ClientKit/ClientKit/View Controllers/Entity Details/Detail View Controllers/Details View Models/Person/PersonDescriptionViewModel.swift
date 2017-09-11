//
//  PersonDescriptionViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonDescriptionViewModel: EntityDetailViewModelable {
    // Specify the concrete type
    public typealias DetailsType = PersonDescription
    public typealias SectionType = (year: String, descriptions: [PersonDescription])
    
    public weak var delegate: EntityDetailViewModelDelegate?
    
    // MARK: - Initialize

    public var sections: [PersonDescription] = [] {
        didSet {
            if sections.isEmpty {
                self.orderedSections = []
                return
            }
            
            var sectionsMap: [String: [PersonDescription]] = [:]
            for description in sections {
                // mapping description to report date's year
                let year = description.effectiveDate == nil ? "" : yearDateFormatter.string(from: description.effectiveDate!)
                var yearsDescriptions = sectionsMap[year] ?? []
                yearsDescriptions.append(description)
                sectionsMap[year] = yearsDescriptions
            }
            
            // add each years descriptions to sections array in order of year
            var orderedSections: [SectionType] = []
            let years = sectionsMap.keys.sorted(by: { $0.localizedCompare($1) == .orderedDescending })
            for year in years {
                if year.characters.count == 0 {
                    orderedSections.append(("Unknown Year", sectionsMap[year]!))
                } else {
                    orderedSections.append((year, sectionsMap[year]!))
                }
            }
            self.orderedSections = orderedSections
        }
    }
    
    // MARK: - Private property
    
    private var collapsedSections: Set<Int> = []
    
    private var orderedSections: [SectionType] = [] {
        didSet {
            delegate?.reloadData()
        }
    }
    
    private var yearDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "YYYY"
        return formatter
    }
    
    // MARK: - Public methods
    
    public func numberOfSections() -> Int {
        return orderedSections.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        return collapsedSections.contains(section) ? 0 : numberOfDescriptions(for: section)
    }
    
    public func numberOfDescriptions(for section: Int) -> Int {
        return orderedSections[ifExists: section]?.descriptions.count ?? 0
    }
    
    public func description(for indexPath: IndexPath) -> PersonDescription? {
        return orderedSections[ifExists: indexPath.section]?.descriptions[ifExists: indexPath.row]
    }
    
    public func cellInfo(for indexPath: IndexPath) -> CellInfo {
        let description = self.description(for: indexPath)
        
        let cellTitle = title(for: description)
        let cellValue = formatedDescription(for: description)
        
        return CellInfo(title: cellTitle, value: cellValue, image: nil)
    }
    
    /// Section header
    public func year(for section: Int) -> String? {
        return orderedSections[ifExists: section]?.year
    }
    
    public func updateCollapsedSections(for section: Int) {
        if collapsedSections.remove(section) == nil {
            // This section wasn't in there and didn't remove
            collapsedSections.insert(section)
        }
    }
    
    public func isExpanded(for section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }
    
    /// Provide info to cal the minimum content height for collectionView
    public func itemForCalculateContentHeight(at indexPath: IndexPath) -> (title: String?, value: String?) {
        let description = item(at: indexPath.row)!
        
        let title = titleForCalculateContentHeight(with: description)
        let value = valueForCalculateContentHeight(with: description)
        
        return (title: title, value: value)
    }

    // MARK: - Private methods

    /// Provides custom formated cell title
    private func title(for description: PersonDescription?) -> String? {
        
        guard let description = description,
            let reportDate = description.reportDate else { return nil }
        
        return DateFormatter.shortDate.string(from: reportDate)
    }
    
    /// Provides custom formated description
    private func formatedDescription(for description: PersonDescription?) -> String? {
        return description?.formatted()
    }
    
    private func titleForCalculateContentHeight(with description: PersonDescription) -> String? {
        return description.reportDate == nil ? nil : "Unknown Date"
    }
    
    private func valueForCalculateContentHeight(with description: PersonDescription) -> String? {
        return description.formatted()
    }
    
    
    // MARK: - Cell Information Models
    public struct CellInfo {
        let title: String?
        let value: String?
        let image: UIImage?
    }
}
