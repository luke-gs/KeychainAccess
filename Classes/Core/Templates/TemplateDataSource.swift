//
//  TemplateDataSource.swift
//  MPOLKit
//
//  Created by Kara Valentine on 19/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// A data source responsible for providing templates to a TemplateHandler.
protocol TemplateDataSource {
    associatedtype TemplateType: Template
    
    func retrieve() -> Promise<Set<TemplateType>?>
    func store(template: TemplateType)
    func delete(template: TemplateType)
}
