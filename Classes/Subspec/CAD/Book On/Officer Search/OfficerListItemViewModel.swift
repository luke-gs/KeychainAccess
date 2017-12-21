//
//  OfficerListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct OfficerListItemViewModel: GenericSearchable {
    
    public var firstName: String
    public var lastName: String
    public var rank: String
    public var callsign: String
    
    public init(firstName: String, lastName: String, rank: String, callsign: String, section: String?, image: UIImage?) {
        self.firstName = firstName
        self.lastName = lastName
        self.rank = rank
        self.callsign = callsign
        self.section = section
        self.image = image
    }
    
    // MARK: - Searchable
    
    public var title: String {
        return "\(firstName) \(lastName)"
    }
    
    public var subtitle: String? {
        return "\(rank)\(ThemeConstants.dividerSeparator)#\(callsign)"
    }
    
    public var section: String?
    public var image: UIImage?
    
    public func matches(searchString: String) -> Bool {
        let searchStringLowercase = searchString.lowercased()
        
        let matchesFirstName = firstName.lowercased().hasPrefix(searchStringLowercase)
        let matchesLastName = lastName.lowercased().hasPrefix(searchStringLowercase)
        let matchesCallsign = callsign.lowercased().hasPrefix(searchStringLowercase)
        
        return matchesFirstName || matchesLastName || matchesCallsign
    }
    
}
