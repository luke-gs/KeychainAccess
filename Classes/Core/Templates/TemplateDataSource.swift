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
public protocol TemplateDataSource {
    associatedtype TemplateType: Template
    
    func retrieve() -> Guarantee<Set<TextTemplate>?>
    func store(template: TemplateType)
    func delete(template: TemplateType)
}
