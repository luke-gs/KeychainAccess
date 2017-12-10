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
    
    private var onTappedMessageBlock: ((UIButton) -> ())?
    private var onTappedCallBlock: ((UIButton) -> ())?


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
        messageButton.addTarget(self, action: #selector(didSelectMessage), for: .touchUpInside)

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
    
    
    @objc private func didSelectCall() {
        onTappedCallBlock?(callButton)
    }
    
    @objc private func didSelectMessage() {
        onTappedMessageBlock?(messageButton)
    }
    
    
    @discardableResult
    /// Called when the call button is tapped
    public func onTappedCall(_ tapped: ((UIButton) -> ())?) -> Self {
        self.onTappedCallBlock = tapped
        return self
    }
    
    @discardableResult
    /// Called when the message button is tapped
    public func onTappedMessage(_ tapped: ((UIButton) -> ())?) -> Self {
        self.onTappedMessageBlock = tapped
        return self
    }
}
