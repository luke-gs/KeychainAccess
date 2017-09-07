//
//  EntityDetailSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Entity Sections

public protocol EntityDetailSectionsDataSource {
    var localizedDisplayName: String { get }
    var detailsViewControllers: [EntityDetailCollectionViewController] { get }
    func fetchModel(for entity: Entity, sources: [MPOLSource]) -> Fetchable
}
