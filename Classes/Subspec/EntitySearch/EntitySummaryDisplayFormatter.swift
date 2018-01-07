//
//  EntitySummaryDisplayFormatter.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation



public class EntitySummaryDisplayFormatter {

    /// Presentable type
    ///
    /// - function->Presentable: Returns a presentable for the given entity.
    /// - none: No presentable available.
    public enum PresentableType {
        case function((MPOLKitEntity) -> Presentable)
        case none
    }

    /// Summary displayable type
    ///
    /// - function->EntitySummaryDisplayable: Returns a summary displayable for the given entity.
    /// - none: No summary displayable available.
    public enum SummaryType {
        case function((MPOLKitEntity) -> EntitySummaryDisplayable)
        case none
    }

    /// Default formatter.
    public static let `default` = EntitySummaryDisplayFormatter()

    private var entityMap = [ObjectIdentifier: (summary: SummaryType, presentable: PresentableType)]()

    public init() { }

    /// Registers an entity type for a summary displayable and a presentable.
    ///
    /// - Parameters:
    ///   - entityType: Type of entity to be registered.
    ///   - summaryType: Summary type to be returned for this entity type.
    ///   - presentableType: Presentable to be returned for this entity type.
    public func registerEntityType(_ entityType: MPOLKitEntity.Type, forSummary summaryType: SummaryType, andPresentable presentableType: PresentableType) {
        entityMap[ObjectIdentifier(entityType)] = (summary: summaryType, presentable: presentableType)
    }

    /// Removes the summary displayable and the presentable for the given entity type.
    ///
    /// - Parameter entityType: Type of entity to be deregistered.
    public func removeRegistrationForEntityType(_ entityType: MPOLKitEntity.Type) {
        entityMap[ObjectIdentifier(entityType)] = nil
    }

    /// Returns a summary displayable for the entity.
    ///
    /// - Parameter entity: The entity.
    /// - Returns: The summary displayable for the entity.
    public func summaryDisplayForEntity(_ entity: MPOLKitEntity) -> EntitySummaryDisplayable? {
        guard let summary = entityMap[ObjectIdentifier(type(of: entity))]?.summary else {
            #if DEBUG
                print("Attempting to generate an EntitySummaryDisplay for \(type(of: entity)). Did you forget to register a summary for this type?")
            #endif
            return nil
        }

        switch summary {
        case .function(let handler):
            return handler(entity)
        case .none:
            return nil
        }
    }

    /// Returns a presentable for the entity.
    ///
    /// - Parameter entity: The entity.
    /// - Returns: The presentable for the entity.
    public func presentableForEntity(_ entity: MPOLKitEntity) -> Presentable? {
        guard let presentable = entityMap[ObjectIdentifier(type(of: entity))]?.presentable else {
            #if DEBUG
                print("Attempting to generate a Presentable for \(type(of: entity)). Did you forget to register a presentable for this type?")
            #endif
            return nil
        }

        switch presentable {
        case .function(let handler):
            return handler(entity)
        case .none:
            return nil
        }
    }

}
