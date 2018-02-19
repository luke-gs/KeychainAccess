//
//  Pickable.swift
//  MPOLKit
//
//  Created by QHMW64 on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation


/// A type that can be picked from a list.
///
/// Types that conform to the `Pickable` protocol can be selected from a list.
public protocol Pickable {

    /// The title for presentation in a picking UI.
    var title: String?    { get }

    /// An additional subtitle description.
    var subtitle: String? { get }
}

extension Pickable {
    func isEqual(to pickable: Pickable) -> Bool {
        if let t1 = title, let t2 = pickable.title {
            let matchingTitles = t1.caseInsensitiveCompare(t2) == .orderedSame
            if let s1 = subtitle, let s2 = pickable.subtitle {
                return matchingTitles && s1.caseInsensitiveCompare(s2) == .orderedSame
            }
            return matchingTitles
        }
        return false
    }
}

public enum PickableSorting {
    case none
    case alphabetical(ascending: Bool)
    case alphabeticalInsensitive(ascending: Bool)
    case custom((Pickable, Pickable) -> Bool)

    public func function() -> (Pickable, Pickable) -> Bool {
        switch self {
        case .none:
            return ( { _, _ in return false })
        case .alphabetical(let ascending):
            return ({
                if let title = $0.title, let title2 = $1.title {
                    if let subtitle = $0.subtitle, let subtitle2 = $1.subtitle {
                        return ascending ? title < title2 && subtitle < subtitle2 : title > title2 && subtitle > subtitle2
                    }
                    return ascending ? title < title2 : title > title2
                }
                return false
            })
        case .alphabeticalInsensitive(let ascending):
            return ({
                if let title = $0.title, let title2 = $1.title {
                    if let subtitle = $0.subtitle, let subtitle2 = $1.subtitle {
                        return ascending ? title.caseInsensitiveCompare(title2) == .orderedAscending && subtitle.caseInsensitiveCompare(subtitle2) == .orderedAscending :
                            title.caseInsensitiveCompare(title2) == .orderedDescending && subtitle.caseInsensitiveCompare(subtitle) == .orderedDescending
                    }
                    return ascending ? title.caseInsensitiveCompare(title2) == .orderedAscending : title.caseInsensitiveCompare(title2) == .orderedDescending
                }
                return false
            })
        case .custom(let sort):
            return sort
        }
    }
}
