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
public class UserDefaultsDataSource: TemplateDataSource {

    public typealias TemplateType = TextTemplate
    var templates: Set<TextTemplate> = []

    /// Used for storing and retrieving from UserDefaults.
    let sourceKey: String

    public init(sourceKey: String) {
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

    public func retrieve() -> Guarantee<Set<TextTemplate>?> {
        return Guarantee<Set<TextTemplate>?>(resolver: { resolver in
            resolver(templates)
        })

//        return Guarantee<Set<TextTemplate>?> { seal in
//            seal.fulfill(templates)
//        }
    }

    public func store(template: TextTemplate) {
        templates.remove(template)
        templates.insert(template)
        updateUserDefaults()
    }

    public func delete(template: TextTemplate) {
        templates.remove(template)
        updateUserDefaults()
    }

    private func updateUserDefaults() {
        let encoder = PropertyListEncoder()
        let propertyList = templates.map { template in
            return try? encoder.encode(template)
        }.removeNils()
        UserDefaults.standard.set(propertyList, forKey: sourceKey)
    }
}
