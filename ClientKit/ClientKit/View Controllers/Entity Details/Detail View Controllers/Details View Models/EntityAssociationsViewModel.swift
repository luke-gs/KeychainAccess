//
//  EntityAssociationsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class EntityAssociationsViewModel: EntityDetailsViewModel<Person> {
    
    // MARK: Initialize
    
    public override var person: Person? {
        didSet {
            let subtitle = self.noContentSubtitle()
            delegate?.updateNoContentSubtitle(subtitle)
            
            sections = person?.associatedPersons ?? []
        }
    }
    
    // MARK: - Public methods
    
    public func noContentSubtitle() -> String? {
        let entityDisplayName: String
        if let entity = person {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        return String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
    public override var sectionHeader: String? {
        let count = numberOfItems()
        return String(format: (count == 1 ? "%d PERSON" : "%d PEOPLE"), count)
    }
    
    public func headerCellInfo(at indexPath: IndexPath) -> HeaderSectionCellInfo {
        let associate = item(at: indexPath.item)!
        let title = associate.summary
        
        let subtitleComponents = [associate.summaryDetail1, associate.summaryDetail2].flatMap({$0})
        let subtitle    = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        let alertColor  = associate.alertLevel?.color
        let actionCount = associate.actionCount
        let source      = associate.source?.localizedBadgeTitle

        
        return HeaderSectionCellInfo(source: source,
                                     title:title,
                                     subtitle: subtitle,
                                     alertColor: alertColor,
                                     actionCount: actionCount)
    }
    
    // MARK: Cell struct
    public struct HeaderSectionCellInfo {
        let source      : String?
        let title       : String?
        let subtitle    : String?
        let alertColor  : UIColor?
        let actionCount : UInt
    }
    
}
