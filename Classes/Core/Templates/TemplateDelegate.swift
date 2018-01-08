//
//  TemplateDelegate.swift
//  MPOLKit
//
//  Delegate for specific TemplateManager behaviour.
//  Handles sources and caching policies.
//
//  Created by Kara Valentine on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit

public protocol TemplateDelegate {
    /// URL used for source interactions.
    var url: URL { get }

    func retrieveCachedTemplates() -> Set<Template>
    func retrieveDeletedNetworkKeys() -> Set<String>
    func retrieveLocalTemplates() -> Set<Template>
    func retrieveNetworkTemplates() -> Set<Template>
}
