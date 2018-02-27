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

