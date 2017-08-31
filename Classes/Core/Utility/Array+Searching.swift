//
//  Array+Searching.swift
//  ClientKit
//
//  Created by Rod Brown on 7/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import Foundation

extension Array {
    
    public func indexes(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        var indexSet = IndexSet()
        for (index, element) in self.enumerated() {
            if try predicate(element) {
                indexSet.insert(index)
            }
        }
        return indexSet
    }
    
    
    public subscript(indexSet: IndexSet) -> [Element] {
        var elements: [Element] = []
        for index in indexSet {
            elements.append(self[index])
        }
        return elements
    }
    
}

