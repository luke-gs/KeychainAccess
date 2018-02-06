//
//  Template.swift
//  MPOLKit
//
//  Created by Kara Valentine on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Core template objects that provides uniqueness.
public final class TemplateCore: Codable {
    /// A UUID.
    public let id: UUID
    /// A timestamp.
    public let timestamp: Date
    
    /// Default initialiser. Provides generated UUID and timestamp (now).
    /// If in doubt, use this initialiser.
    public init() {
        self.id = UUID()
        self.timestamp = Date()
    }
    
    /// Initialiser with id and timestamp parameters.
    /// Use this in cases where these have already been generated (e.g.
    /// they are coming from a persistent source).
    public init(id: UUID, timestamp: Date) {
        self.id = id
        self.timestamp = timestamp
    }
}

/// Base Template protocol used for template data sources.
/// Codable behaviour is provided for free.
public protocol Template: Codable, Hashable {
    /// Core member providing core template functionality through composition.
    var core: TemplateCore { get }
}

/// Extension of Template providing implementation of `hashValue` and `==`.
public extension Template {
    public var hashValue: Int {
        return core.id.hashValue
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.core.id == rhs.core.id
    }
}
