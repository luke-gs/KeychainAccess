//
//  TempTemplate.swift
//  MPOLKit
//
//  Created by Kara Valentine on 1/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class TextTemplate: Template {
    
    public var core: TemplateCore
    public let name: String
    public let description: String
    public let value: String
    
    convenience init(name: String, description: String, value: String) {
        self.init(name: name, description: description, value: value, core: TemplateCore())
    }
    
    init(name: String, description: String, value: String, core: TemplateCore) {
        self.name = name
        self.description = description
        self.value = value
        self.core = core
    }
    
    // having to implement this in each implementation of `Template` is bad
    public static func ==(lhs: TextTemplate, rhs: TextTemplate) -> Bool {
        return lhs.core.id == rhs.core.id
    }
}
