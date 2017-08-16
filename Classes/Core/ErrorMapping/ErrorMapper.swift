//
//  ErrorMapper.swift
//  MPOLKit
//
//  Created by Herli Halim on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class ErrorMapper {
    
    public let definitions: [ErrorMappable]
    
    public init(definitions: [ErrorMappable]) {
        self.definitions = definitions
    }
    
    public func mappedError(from error: Error) -> Error {
        guard let definition = definition(for: error),
              let mapped = definition.mappedError(from: error) else {
            return error
        }
        return mapped
    }
    
    private func definition(for error: Error) -> ErrorMappable? {
        return definitions.first(where: { type(of: $0).supportedType == type(of: error) })
    }
}
