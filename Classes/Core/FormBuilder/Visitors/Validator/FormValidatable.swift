//
//  FormValidatable.swift
//  MPOLKit
//
//  Created by KGWH78 on 26/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol FormValidatable {

    var validator: Validator { get }

    var candidate: Any? { get }

    func reloadLiveValidationState()

    func reloadSubmitValidationState()

    func validateValueForSubmission() -> ValidateResult
    
}
