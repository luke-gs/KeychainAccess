//
//  CautionDetailsViewController.swift
//  MPOLKit
//
//  Created by Herli Halim on 25/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class CautionDetailsViewController: FormCollectionViewController {

    open var fieldContact: FieldContact? {
        didSet {
        }
    }
    
    public override init() {
        super.init()
        
        title = NSLocalizedString("Caution", comment: "Form Title")
    }

}
