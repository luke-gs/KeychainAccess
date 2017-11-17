//
//  MapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol MapFilterViewModel {
    
    func createViewController() -> UIViewController
    func titleText() -> String?
    func footerButtonText() -> String?
    
    
}
