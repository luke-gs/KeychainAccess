//
//  TemplateDemoDelegate.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

extension Template {
    var propertyListRepresentation: [String: String] {
        return ["name": name, "description": description, "value": value]
    }
}

class TemplateDemoDelegate: TemplateDelegate {
    var url: URL = try! "http://google.com".asURL()
    let userDefaults = UserDefaults.standard

    let cachedKey = "cached"
    let localKey = "local"

    func store(_ templates: Set<Template>, forKey key: String) {
        let propertyList = templates.map { $0.propertyListRepresentation }
        userDefaults.set(propertyList, forKey: key)
    }

    func retrieveTemplates(forKey key: String) -> Set<Template>? {
        guard let data = userDefaults.object(forKey: key) else {
            return nil
        }
        guard let templatePropertySet = data as? [[String:String]] else {
            return nil
        }
        let templateSet = templatePropertySet.map { (p) in
            return Template(name: p["name"]!, description: p["description"]!, value: p["value"]!)
        }
        return Set(templateSet)
    }

    func storeCachedTemplates(templates: Set<Template>) {
        store(templates, forKey: cachedKey)
    }

    func storeLocalTemplates(templates: Set<Template>) {
        store(templates, forKey: localKey)
    }

    func retrieveCachedTemplates() -> Set<Template>? {
        return retrieveTemplates(forKey: cachedKey)
    }

    func retrieveLocalTemplates() -> Set<Template>? {
        return retrieveTemplates(forKey: localKey)
    }

    func retrieveNetworkTemplates() -> Promise<Set<Template>?> {
        return Promise<Set<Template>?> { fulfil, reject in
            fulfil(Set([
                Template(name: "Network Template 1", description: "The first network template.", value: "Open sesame!"),
                Template(name: "Network Template 2", description: "The second network template.", value: "The grid bug bites! You get zapped!")
                ]))
        }
    }

}
