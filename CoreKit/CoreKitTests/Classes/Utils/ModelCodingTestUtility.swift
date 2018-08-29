//
//  ModelCodingTestCase.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Foundation


extension XCTestCase {
    
    func clone<T: NSSecureCoding>(object: T) -> T {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        let cloned = NSKeyedUnarchiver.unarchiveObject(with: data) as! T
        return cloned
    }
    
}
