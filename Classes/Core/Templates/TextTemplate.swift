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
    
    public convenience init(name: String, description: String, value: String) {
        self.init(name: name, description: description, value: value, core: TemplateCore())
    }
    
    public init(name: String, description: String, value: String, core: TemplateCore) {
        self.name = name
        self.description = description
        self.value = value
        self.core = core
    }
}
