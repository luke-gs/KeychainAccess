//
//  Person.swift
//  Pods
//
//  Created by Rod Brown on 17/5/17.
//
//

import Foundation

open class Person: Entity {
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
}
