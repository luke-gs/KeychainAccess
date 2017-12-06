//
//  CommsButtonHandler.swift
//  MPOLKit
//
//  Created by Kyle May on 6/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CommsButtonHandler {
    
    /// Displays an action sheet with the comms buttons
    @objc open static func didSelectCompactCommsButton(for contactNumber: String) {
        let actionSheet = UIAlertController(title: contactNumber, message: nil, preferredStyle: .actionSheet)
        let text = UIAlertAction(title: "Message", style: .default) { _ in
            self.didSelectMessage(for: contactNumber)
        }
        text.setValue(AssetManager.shared.image(forKey: .message), forKey: "image")
        
        let call = UIAlertAction(title: "Call", style: .default) { _ in
            self.didSelectCall(for: contactNumber)
        }
        call.setValue(AssetManager.shared.image(forKey: .audioCall), forKey: "image")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(text)
        actionSheet.addAction(call)
        actionSheet.addAction(cancel)
        
        AlertQueue.shared.add(actionSheet)
    }
    
    /// Opens the phone or FaceTime app or throws an error if the device does not support calling
    @objc open static func didSelectCall(for contactNumber: String) {
        if let contactNumber = contactNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "tel://\(contactNumber)"), UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AlertQueue.shared.addSimpleAlert(title: contactNumber, message: "This device does not support calling or the phone number is invalid.")
        }
    }
    
    /// Opens the message app or throws an error if the device does not support calling
    @objc open static func didSelectMessage(for contactNumber: String) {
        if let contactNumber = contactNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "sms:\(contactNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AlertQueue.shared.addSimpleAlert(title: contactNumber, message: "This device does not support messaging or the phone number is invalid.")
        }
    }
}
