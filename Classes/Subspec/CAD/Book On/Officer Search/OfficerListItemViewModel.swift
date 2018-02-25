//
//  OfficerListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct OfficerListItemViewModel: CustomSearchDisplayable {
    
    public var firstName: String?
    public var lastName: String?
    public var initials: String?
    public var rank: String?
    public var callsign: String
    
    public init(firstName: String?, lastName: String?, initials: String?, rank: String?, callsign: String, section: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.initials = initials
        self.rank = rank
        self.callsign = callsign
        self.section = section
    }
    
    // MARK: - Searchable
    
    public var title: String? {
        return [firstName, lastName].joined()
    }
    
    public var subtitle: String? {
        return [rank, "#\(callsign)"].joined(separator: ThemeConstants.dividerSeparator)
    }
    
    public var section: String?
    public var image: UIImage? {
        if let initials = initials {
            return UIImage.thumbnail(withInitials: initials).withCircleBackground(tintColor: nil,
                                                                                  circleColor: .disabledGray,
                                                                                  style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                                padding: CGSize(width: 14, height: 14)))
        }
        return nil
    }
    
    public func contains(_ searchText: String) -> Bool {
        let searchStringLowercase = searchText.lowercased()
        
        let matchesFirstName = firstName?.lowercased().hasPrefix(searchStringLowercase)
        let matchesLastName = lastName?.lowercased().hasPrefix(searchStringLowercase)
        let matchesCallsign = callsign.lowercased().hasPrefix(searchStringLowercase)
        
        return matchesFirstName.isTrue || matchesLastName.isTrue || matchesCallsign
    }
    
}
