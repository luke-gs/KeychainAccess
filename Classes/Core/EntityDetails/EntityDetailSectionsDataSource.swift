//
//  EntityDetailSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

////// Entity Sections

public protocol EntityDetailSectionUpdatable: class {
    var genericEntity: MPOLKitEntity? { get set }
    var loadingManager: LoadingStateManager { get }
}

public protocol EntityDetailSectionsDataSource {

    var initialSource: EntitySource { get set }
    var sources: [EntitySource] { get }

    var baseEntity: MPOLKitEntity { get }
    func navTitleSuitable(for traitCollection: UITraitCollection) -> String

    var localizedDisplayName: String { get }
    var detailViewControllers: [EntityDetailSectionUpdatable] { get }
    func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable
}

public extension EntityDetailSectionsDataSource {
    func navTitleSuitable(for traitCollection: UITraitCollection) -> String {
        if traitCollection.horizontalSizeClass == .compact {
            // Use the title of the entity, as we are not showing a sidebar in compact mode
            if let entity = baseEntity as? EntitySummaryDisplayable, let title = entity.title {
                return title
            }
        }
        // Use a generic sidebar title
        return NSLocalizedString("Details", comment: "Title for for entity details")
    }
}
