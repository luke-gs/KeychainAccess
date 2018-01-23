//
//  UserDefaultsDataSource.swift
//  MPOLKit
//
//  Created by Kara Valentine on 19/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Sample implementation of TemplateDataSource that uses UserDefaults.
class UserDefaultsDataSource: TemplateDataSource {

    typealias TemplateType = TextTemplate
    var templates: Set<TextTemplate> = []

    /// Used for storing and retrieving from UserDefaults.
    let sourceKey: String

    init(sourceKey: String) {
        self.sourceKey = sourceKey

        // load templates from user defaults
        guard let dataset = UserDefaults.standard.object(forKey: sourceKey) as? [Data] else {
            return
        }

        let decoder = PropertyListDecoder()
        let templatesFromData = dataset.map { data in
            return try! decoder.decode(TextTemplate.self, from: data)
        }

        templates = Set(templatesFromData)
    }

    func retrieve() -> Promise<Set<TextTemplate>?> {
        return Promise<Set<TextTemplate>?> { fulfil, reject in
            fulfil(templates)
        }
    }

    func store(template: TextTemplate) {
        templates.remove(template)
        templates.insert(template)
        updateUserDefaults()
    }

    func delete(template: TextTemplate) {
        templates.remove(template)
        updateUserDefaults()
    }

    func updateUserDefaults() {
        let encoder = PropertyListEncoder()
        let propertyList = templates.map { template in
            return try? encoder.encode(template)
        }.removeNils()
        UserDefaults.standard.set(propertyList, forKey: sourceKey)
    }
}
