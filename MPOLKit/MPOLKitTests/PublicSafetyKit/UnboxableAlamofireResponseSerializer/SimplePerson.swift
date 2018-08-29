//
//  SimplePerson.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

struct SimplePerson: Unboxable {
    
    let firstName: String
    let surname: String
    
    init(unboxer: Unboxer) throws {
        self.firstName = try unboxer.unbox(key: "first_name")
        self.surname = try unboxer.unbox(key: "last_name")
    }
    
}
