//
//  TemplateManager.swift
//  MPOLKit
//
//  Singleton responsible for providing callsite access to templates.
//  Features a delegate property to specify source access behaviour.
//
//  Created by Kara Valentine on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public class TemplateManager {

    static let shared: TemplateManager = TemplateManager()

    // cached network templates - retrieved from last session
    private var cachedTemplates: Set<Template> = [] {
        didSet {
            if cachedTemplates != oldValue {
                networkTemplates.formUnion(cachedTemplates)
            }
        }
    }

    // network templates - retrieved from the network source this session
    private var networkTemplates: Set<Template> = [] {
        didSet {
            if networkTemplates != oldValue {
                networkTemplates.formUnion(cachedTemplates)
            }
        }
    }

    // a list of deleted network template keys - retrieved from last session
    private var deletedNetworkKeys: Set<String> = [] {
        didSet {
            if deletedNetworkKeys != oldValue {
                createCombinedTemplates()
            }
        }
    }

    // a list of user-created templates - retrieved from last session
    private var localTemplates: Set<Template> = [] {
        didSet {
            if localTemplates != oldValue {
                createCombinedTemplates()
            }
        }
    }

    // the complete list of templates presented to the user
    private var combinedTemplates: Set<Template> = []

    var delegate: TemplateDelegate? {
        didSet {
            loadExternalTemplates()
        }
    }

    private init() {
        loadExternalTemplates()
    }

    func loadExternalTemplates() {
        cachedTemplates = delegate?.retrieveCachedTemplates() ?? []
        deletedNetworkKeys = delegate?.retrieveDeletedNetworkKeys() ?? []
        localTemplates = delegate?.retrieveLocalTemplates() ?? []

        // load online things
        networkTemplates = delegate?.retrieveNetworkTemplates() ?? []
    }

    func createCombinedTemplates() {
        // fill in blanks in network templates with cached templates
        networkTemplates.formUnion(cachedTemplates)

        // combined templates begins with the merged network templates
        combinedTemplates = networkTemplates

        // remove all deleted keys
        combinedTemplates.subtract(deletedNetworkKeys.map { key in Template(name: key)})

        // merge in local templates, overwriting existing templates
        combinedTemplates = localTemplates.union(combinedTemplates)

        // combinedTemplates is now up to date!
    }

    func template(withName name: String) -> Template? {
        return combinedTemplates.first { template in template.name == name }
    }

    func allTemplates() -> Set<Template> {
        return combinedTemplates
    }

    @discardableResult
    func add(template: Template) -> Bool {
        localTemplates.insert(template)
        return true
    }

    @discardableResult
    func edit(template: Template) -> Bool {
        // insert does nothing while the template exists within the set,
        // hence it must be removed to provide "editing" behaviour.
        localTemplates.remove(template)
        localTemplates.insert(template)
        return true
    }

    @discardableResult
    func remove(templateWithName name: String) -> Bool {
        if let template = localTemplates.first(where: { template in template.name == name }) {
            localTemplates.remove(template)
        }
        return true
    }

    func removeAll() {
        localTemplates.removeAll()
    }


}
