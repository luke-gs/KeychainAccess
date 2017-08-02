//
//  MPOL.swift
//  MPOL
//
//  Created by KGWH78 on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit



struct MPOL {
    static var shared = MPOL()
    
    var manager = APIManager(configuration: APIManagerDefaultConfiguration<MPOLSource>(url: "http://mock-api.mpol.solutions"))
}
