//
//  FieldContactDetailsViewController.swift
//  Pods
//
//  Created by Rod Brown on 25/5/17.
//
//

import UIKit

open class FieldContactDetailsViewController: FormCollectionViewController {
    
    open var fieldContact: FieldContact? {
        didSet {
        }
    }
    
    public override init() {
        super.init()
        
        title = NSLocalizedString("Field Contact", comment: "Form Title")
    }
    
}
