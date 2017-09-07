//
//  EntityAssociationsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EntityAssociationsViewModel: EntityDetailViewModelable {
    
    public typealias DetailsType  = Section
    
    // MARK: Initialize
    private var associatedPersons: [Person]  = []
    private var associatedVehicles: [Vehicle] = []
    
    public weak var delegate: EntityDetailViewModelDelegate?

    public var entity: Entity? {
        didSet {
            associatedPersons = entity?.associatedPersons ?? []
            associatedVehicles = entity?.associatedVehicles ?? []
            
            let count = associatedPersons.count + associatedVehicles.count
            delegate?.updateSidebarItemCount(UInt(count))
            
            var sections: [Section] = []
            if associatedPersons.isEmpty == false {
                sections.append(.people(associatedPersons))
            }
            if associatedVehicles.isEmpty == false {
                sections.append(.vehicles(associatedVehicles))
            }
            self.sections = sections
        }
    }
    
    public var sections: [DetailsType] = [] {
        didSet {
            let state: LoadingStateManager.State = sections.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }
    
    public var style: SearchResultStyle = .grid

    // MARK: - Public methods
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        return sections[section].count
    }
    
    public func associate(at indexPath: IndexPath) -> EntitySummaryDisplayable {
        let itemSection = item(at: indexPath.section)!
        
        switch itemSection {
        case .people(let persons):
            return AssociatedPerson(associate: persons[indexPath.item])
        case .vehicles(let vehicles):
            return AssociatedVehicle(associate: vehicles[indexPath.item])
        }
    }
    
    /// Section type 
    public enum Section {
        case people([Person])
        case vehicles([Vehicle])
        
        var title: String {
            switch self {
            case .people(let associates):
                let count = associates.count
                return String(format: (count == 1 ? "%d PERSON" : "%d PEOPLE"), count)
            case .vehicles(let associates):
                let count = associates.count
                return String(format: (count == 1 ? "%d VEHICLE" : "%d VEHICLES"), count)
            }
        }
        
        var count: Int {
            switch self {
            case .people(let associates):
                return associates.count
            case .vehicles(let associates):
                return associates.count
            }
        }
        
        func associate(at index: Int) -> Entity {
            switch self {
            case .people(let associates):
                return associates[index]
            case .vehicles(let associates):
                return associates[index]
            }
        }
        
    }
}
