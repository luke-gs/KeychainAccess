//
//  PatrolAreaListItemViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

public struct PatrolAreaListItemViewModel: GenericSearchable {
    
    public var patrolArea: String
    
    public init(patrolArea: String) {
        self.patrolArea = patrolArea
    }
    
    // MARK: - Searchable
    
    public var title: String {
        return patrolArea
    }
    
    public var section: String? {
        return "PATROL AREAS"
    }
    
    public var subtitle: String?
    public var image: UIImage?
    
    public func matches(searchString: String) -> Bool {
        let searchStringLowercase = searchString.lowercased()
        return patrolArea.lowercased().hasPrefix(searchStringLowercase)
    }

}
