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
    var localizedDisplayName: String { get }
    var detailViewControllers: [EntityDetailSectionUpdatable] { get }
    func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable
}
