//
//  SearchProxyViewController.swift
//  CAD
//
//  Created by Kyle May on 24/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class SearchProxyViewController: UIViewController {
    
    private let searchAppUrl = URL(string: "\(SEARCH_APP_SCHEME)://")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = searchAppUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if !success {
                    AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Failed to open Search app", comment: ""))
                }
            })
        }
        statusTabBarController?.selectedViewController = statusTabBarController?.previousSelectedViewController
    }
    
}
