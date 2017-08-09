//
//  EntityAssociationsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EntityAssociationsViewModel: EntityDetailsViewModelable {
    
    public typealias DetailsType  = Section
    
    // MARK: Initialize
    private var associatedPersons: [Person] = []
    private var associatedVehicles: [Vehicle] = []
    
    public weak var delegate: EntityDetailsViewModelDelegate?

    public var entity: Entity? {
        didSet {
            let subtitle = self.noContentSubtitle()
            delegate?.updateNoContentSubtitle(subtitle)

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
    
    public var sections: [DetailsType]? = [] {
        didSet {
            let state: LoadingStateManager.State = sections!.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }
    
    // MARK: - Public methods
    
    public func numberOfSections() -> Int {
        return sections!.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        return sections![section].count
    }
    
    public func noContentSubtitle() -> String? {
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        return String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
    public func associate(at indexPath: IndexPath) -> Entity {
        return item(at: indexPath.section)!.associate(at: indexPath.item)
    }
    
    public func headerCellInfo(at indexPath: IndexPath) -> HeaderSectionCellInfo {
        let associate = self.associate(at: indexPath)
        
        let title = associate.summary
        let subtitleComponents = [associate.summaryDetail1, associate.summaryDetail2].flatMap({$0})
        let subtitle    = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        let alertColor  = associate.alertLevel?.color
        let actionCount = associate.actionCount
        let source      = associate.source?.localizedBadgeTitle

        
        return HeaderSectionCellInfo(associate: associate,
                                     source: source,
                                     title:title,
                                     subtitle: subtitle,
                                     alertColor: alertColor,
                                     actionCount: actionCount)
    }
    
    // MARK: Cell struct
    public struct HeaderSectionCellInfo {
        let associate   : Entity
        let source      : String?
        let title       : String?
        let subtitle    : String?
        let alertColor  : UIColor?
        let actionCount : UInt
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
