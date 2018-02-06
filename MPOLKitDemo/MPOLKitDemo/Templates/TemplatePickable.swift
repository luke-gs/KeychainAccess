//
//  TemplatePickable.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension TextTemplate: Pickable {
    public var title: String? {
        return name
    }

    public var subtitle: String? {
        return description
    }
}
