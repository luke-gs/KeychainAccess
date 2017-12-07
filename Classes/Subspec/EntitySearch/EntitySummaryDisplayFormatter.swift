//
//  EntitySummaryDisplayFormatter.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation



public class EntitySummaryDisplayFormatter {

    public enum PresentableType {
        case function((MPOLKitEntity) -> Presentable)
    }

    public enum SummaryType {
        case function((MPOLKitEntity) -> EntitySummaryDisplayable)
    }

    public static let `default` = EntitySummaryDisplayFormatter()

    private var entityMap = [ObjectIdentifier: (summary: SummaryType, presentable: PresentableType)]()

    public init() { }

    public func registerEntityType(_ entityType: MPOLKitEntity.Type, forSummary summaryType: SummaryType, andPresentable presentableType: PresentableType) {
        entityMap[ObjectIdentifier(entityType)] = (summary: summaryType, presentable: presentableType)
    }

    public func removeRegistrationForEntityType(_ entityType: MPOLKitEntity.Type) {
        entityMap[ObjectIdentifier(entityType)] = nil
    }

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
        }
    }

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
        }
    }

}
