//
//  SubmissionValidationVisitor.swift
//  MPOLKit
//
//  Created by KGWH78 on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// This visitor will silently validate the item that implements `FormValidatable`
/// and return the validation result without updating the validation text.
public class SubmissionValidationVisitor: FormVisitor {

    public var result: ValidateResult = .valid

    public func visit(_ object: FormItem) {
        guard let item = object as? FormValidatable else { return }
        result = item.validateValueForSubmission()
    }

}
