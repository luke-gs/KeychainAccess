//
//  TemplateHandler.swift
//  MPOLKit
//
//  Created by Kara Valentine on 22/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// A class that provides access to a TemplateDataSource.
public final class TemplateHandler<T: TemplateDataSource> {

    public let source: T

    public init(source: T) {
        self.source = source
    }
}
