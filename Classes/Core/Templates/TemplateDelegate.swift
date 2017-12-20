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

public enum TemplateSource {
    /// A local source.
    case local
    /// A network source.
    case network(cachePolicy: CachePolicy)
}

public enum CachePolicy {
    /// Load from source before every interaction.
    case instant
    /// If n seconds have passed since the last interaction, load from source.
    case after(seconds: Int)
    /// On a n second loop, load from source.
    case interval(seconds: Int)
}

public protocol TemplateDelegate {
    typealias Templates = [TemplateManager.Key: TemplateManager.Template]

    /// URL used for source interactions.
    var url: URL { get }

    /// Determines load/save behaviour.
    var source: TemplateSource { get }

    /// Retrieve templates from source
    func retrieveTemplatesFromSource() -> Templates

    /// Do source.templates = templates
    func updateSource(withTemplates templates: Templates)

    /// Called whenever TemplateManager changes its internal template dictionary.
    func templatesModified(templates: Templates, forKey key: TemplateManager.Key)
}
