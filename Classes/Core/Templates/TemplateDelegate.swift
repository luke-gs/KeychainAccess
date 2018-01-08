//
//  TemplateDelegate.swift
//  MPOLKit
//
//  Delegate for specific TemplateManager behaviour.
//  Handles storing and retrieving external templates.
//
//  Created by Kara Valentine on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit

public protocol TemplateDelegate {
    /// URL used for source interactions.
    var url: URL { get }

    func storeCachedTemplates(templates: Set<Template>)
    func storeLocalTemplates(templates: Set<Template>)

    func retrieveCachedTemplates() -> Set<Template>
    func retrieveLocalTemplates() -> Set<Template>
    func retrieveNetworkTemplates() -> Promise<Set<Template>>
}
