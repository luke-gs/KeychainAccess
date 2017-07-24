//
//  NoContentCollectionViewController.swift
//  MPOLKitDemo
//
//  Created by Rod Brown on 18/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let reuseIdentifier = "Cell"

class NoContentCollectionController: FormCollectionViewController {

    override init() {
        super.init()
        
        title = "Loading & No Content"
        
        loadingManager.state = .loading
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingManager.noContentTitleLabel.text = "No Content"
        loadingManager.noContentSubtitleLabel.text = "This is an example of a form collection with no content."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.loadingManager.state = .noContent
        }
    }
    
}
