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

    // delegate reloads its data when it's assigned
    var delegate: TemplateDelegate? {
        didSet {
            loadExternalTemplates()
        }
    }

    private init() {
        loadExternalTemplates()
    }

    // reload "external" data from delegate - cached, local and network templates
    private func loadExternalTemplates() {
        cachedTemplates = delegate?.retrieveCachedTemplates() ?? []
        localTemplates = delegate?.retrieveLocalTemplates() ?? []

        // load online things
        delegate?.retrieveNetworkTemplates().then { result in
            self.networkTemplates = result
        }.always{}
    }

    /// Store the current templates according to the delegate's logic for future sessions.
    /// This must be called by any dependents in order to allow any templates to be saved
    /// between sessions.
    func saveExternalTemplates() {
        delegate?.storeCachedTemplates(templates: networkTemplates)
        delegate?.storeLocalTemplates(templates: localTemplates)
    }

    // combines all template sets to form the set presented to users
    private func createCombinedTemplates() {
        // fill in blanks in network templates with cached templates
        networkTemplates.formUnion(cachedTemplates)

        // merge in local templates, overwriting existing templates
        combinedTemplates = localTemplates.union(networkTemplates)

        // combinedTemplates is now up to date!
    }

    // get a template with a name
    func template(withName name: String) -> Template? {
        return combinedTemplates.first { template in template.name == name }
    }

    // get all templates
    func allTemplates() -> Set<Template> {
        return combinedTemplates
    }

    /// Adds a template if no local template with that name exists.
    /// Returns true if successful, false otherwise.
    @discardableResult
    func add(template: Template) -> Bool {
        let exists = localTemplates.contains { localTemplate in localTemplate.name == template.name }
        localTemplates.insert(template)
        return !exists
    }

    /// Replaces a template that has this template's name with this template.
    /// Returns true if successful, false otherwise.
    @discardableResult
    func edit(template: Template) -> Bool {
        let exists = localTemplates.contains { localTemplate in localTemplate.name == template.name }
        // insert does nothing while the template exists within the set,
        // hence it must be removed first to provide "editing" behaviour.
        localTemplates.remove(template)
        localTemplates.insert(template)
        return exists
    }

    /// Removes a template with a given name if it exists.
    /// Returns true if successful, false otherwise.
    @discardableResult
    func remove(templateWithName name: String) -> Bool {
        if let template = localTemplates.first(where: { template in template.name == name }) {
            localTemplates.remove(template)
            return true
        }
        return false
    }

    // remove all local templates
    func removeAll() {
        localTemplates.removeAll()
    }
}
