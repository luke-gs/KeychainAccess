//
//  PatrolAreaListItemViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit
import PatternKit
public struct PatrolAreaListItemViewModel: CustomSearchDisplayable {

    public var patrolArea: String

    public init(patrolArea: String) {
        self.patrolArea = patrolArea
    }

    // MARK: - Searchable

    public var title: StringSizable? {
        return patrolArea
    }

    public var section: String?
    public var subtitle: StringSizable?
    public var image: UIImage?

    public func contains(_ searchText: String) -> Bool {
        let searchStringLowercase = searchText.lowercased()
        return patrolArea.lowercased().hasPrefix(searchStringLowercase)
    }

}
