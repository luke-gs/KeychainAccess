//
//  OfficerCommunicationsView.swift
//  MPOLKit
//
//  Created by Kyle May on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class OfficerCommunicationsView: UIView {
    
    private var stackView: UIStackView!
    private var contactNumber: String

    public let messageButton = DisableableButton(frame: .zero)
    public let callButton = DisableableButton(frame: .zero)
    
    public init(frame: CGRect, commsEnabled: (text: Bool, call: Bool), contactNumber: String) {
        self.contactNumber = contactNumber
        super.init(frame: frame)
        
        messageButton.setImage(AssetManager.shared.image(forKey: .message), for: .normal)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.enabledColor = .brightBlue
        messageButton.disabledColor = .disabledGray
        messageButton.isEnabled = commsEnabled.text
        
        callButton.setImage(AssetManager.shared.image(forKey: .audioCall), for: .normal)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.enabledColor = .brightBlue
        callButton.disabledColor = .disabledGray
        callButton.isEnabled = commsEnabled.call
        callButton.addTarget(self, action: #selector(didSelectCall), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [messageButton, callButton])
        
        stackView.spacing = 24
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    @objc open func didSelectCall() {
        if let url = URL(string: "tel://\(contactNumber.trimmingPhoneNumber())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AlertQueue.shared.addSimpleAlert(title: contactNumber, message: "This device does not support calling or the phone number is invalid.")
        }
    }
    
    @objc open func didSelectMessage() {
        if let url = URL(string: "sms:\(contactNumber.trimmingPhoneNumber())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AlertQueue.shared.addSimpleAlert(title: contactNumber, message: "This device does not support messaging or the phone number is invalid.")
        }
    }
    
}
