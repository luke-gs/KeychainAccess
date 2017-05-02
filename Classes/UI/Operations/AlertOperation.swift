//
//  AlertOperation.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// An operation for presenting an alert within the `AlertQueue`.
open class AlertOperation: Operation {
    
    // MARK: - Properties
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    
    open var title: String? {
        get {
            return alertController.title
        }
        set {
            alertController.title = newValue
            name = newValue
        }
    }
    
    open var message: String? {
        get {
            return alertController.message
        }
        set {
            alertController.message = newValue
        }
    }

    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        
        addCondition(AlertExclusiveCondition())
        addCondition(ViewControllerExclusiveCondition())
    }
    
    
    // MARK: - Actions
    
    open func addAction(_ title: String, style: UIAlertActionStyle = .default, preferred: Bool = false, handler: ((AlertOperation) -> Void)? = nil) {
        
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            handler?(strongSelf)
            strongSelf.finish()
        }
        
        alertController.addAction(action)
        
        if preferred {
            alertController.preferredAction = action
        }
    }
    
    
    // MARK: - Execution
    
    open override func execute() {
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction("OK")
            }
            AlertQueue.shared.add(self.alertController)
        }
    }
}

