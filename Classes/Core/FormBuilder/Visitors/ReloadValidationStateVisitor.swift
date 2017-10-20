//
//  ReloadValidationStateVisitor.swift
//  MPOLKit
//
//  Created by KGWH78 on 26/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// This visitor will validate and reload the current validation state of the form item if it implements `FormValidatable`.
public class ReloadValidationStateVisitor: FormVisitor {

    public func visit(_ object: FormItem) {
        guard let item = object as? FormValidatable else { return }
        item.reloadSubmitValidationState()
    }

}
