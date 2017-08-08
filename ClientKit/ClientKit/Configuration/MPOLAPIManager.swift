//
//  MPOL.swift
//  MPOL
//
//  Created by KGWH78 on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


// App convenience way to hold into APIManager.
// Allow setting the `shared` due to that it's extremely likely that changing URL
// on the fly will happen.
// The app will have to perform its own logic when switching the `shared` manager.
public struct MPOLAPIManager {
    private static var sharedAPIManager = MPOLAPIManager()
    private var apiManager = APIManager(configuration: APIManagerDefaultConfiguration<MPOLSource>(url: "http://mock-api.mpol.solutions"))
    
    public static var shared = MPOLAPIManager.sharedAPIManager.apiManager {
        didSet {
            MPOLAPIManager.sharedAPIManager.apiManager = shared
        }
    }
}
