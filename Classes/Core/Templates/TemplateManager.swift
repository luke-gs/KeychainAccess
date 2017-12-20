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

    public typealias Key = String
    public typealias Template = String

    private var templates: [Key: Template] = [:]

    var delegate: TemplateDelegate?

    private init() {}

    func template(forKey key: Key) -> Template? {
        return templates[key]
    }

    func allTemplates() -> [Template] {
        return Array(templates.values)
    }

    /// Only succeeds if a template does not exist for the key.
    func add(template: Template, forKey key: Key) {
        if !templates.keys.contains(key) {
            templates[key] = template
            dictionaryModified(forKey: key)
        }
    }

    /// The opposite of add(template:key:); only succeeds if a template DOES exist
    /// for the key.
    func edit(template: Template, forKey key: Key) {
        if templates.keys.contains(key) {
            templates[key] = template
            dictionaryModified(forKey: key)
        }
    }

    func remove(templateForKey key: Key) {
        if templates.keys.contains(key) {
            templates[key] = nil
            dictionaryModified(forKey: key)
        }
    }

    /// Removes all templates.
    func removeAll() {
        templates = [:]
    }

    /// Do any async things that are required to maintain the source copy's parity.
    private func dictionaryModified(forKey key: Key) {
        delegate?.templatesModified(templates: templates, forKey: key)
    }
}
