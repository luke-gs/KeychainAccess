//
//  Transformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

/// Protocol used by objects that may transform values into some other value
public protocol Transformer {
    
    /// The type of value that this transformer accepts as input
    associatedtype TransformerOriginalValueType
    
    /// The type of value that this transformer returns as output
    associatedtype TransformerTransformedValueType
    
    func transform(_ value: TransformerOriginalValueType) -> TransformerTransformedValueType?
    
    func reverse(_ transformedValue: TransformerTransformedValueType) -> TransformerOriginalValueType?
    
}

/// Protocol that extends transformer that allows optional value to be passed in.
/// Generally will be useful when transforming values from external system.
public protocol OptionalTransformer: Transformer {
    
    func transform(_ value: TransformerOriginalValueType?) -> TransformerTransformedValueType?
    
    func reverse(_ transformedValue: TransformerTransformedValueType?) -> TransformerOriginalValueType?

}

public extension OptionalTransformer {
    
    public func transform(_ value: TransformerOriginalValueType?) -> TransformerTransformedValueType? {
        guard let value = value else {
            return nil
        }
        return transform(value)
    }
    
    public func reverse(_ transformedValue: TransformerTransformedValueType?) -> TransformerOriginalValueType? {
        guard let transformedValue = transformedValue else {
            return nil
        }
        return reverse(transformedValue)
    }
}
