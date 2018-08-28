//
//  ErrorMappable.swift
//  MPOLKit
//
//  Created by Herli Halim on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol ErrorMappable {
    func mappedError(from error: Error) -> MappedError?
    static var supportedType: Error.Type { get }
}
