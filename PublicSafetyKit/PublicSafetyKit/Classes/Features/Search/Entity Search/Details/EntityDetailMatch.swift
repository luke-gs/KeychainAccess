//
//  EntityDetailMatch.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Defines entity details matches
public struct EntityDetailMatch {

    /// The source to match
    public var sourceToMatch: EntitySource

    /// Whether the source should be matched automatically
    public var shouldMatchAutomatically: Bool

    public init(sourceToMatch: EntitySource, shouldMatchAutomatically: Bool = true) {
        self.sourceToMatch = sourceToMatch
        self.shouldMatchAutomatically = shouldMatchAutomatically
    }
}
