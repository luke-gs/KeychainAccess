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

    public let messageButton = DisableableButton(frame: .zero)
    public let callButton = DisableableButton(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageButton.setImage(AssetManager.shared.image(forKey: .message), for: .normal)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.enabledColor = .brightBlue
        messageButton.disabledColor = .disabledGray
        
        callButton.setImage(AssetManager.shared.image(forKey: .audioCall), for: .normal)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.enabledColor = .brightBlue
        callButton.disabledColor = .disabledGray
        
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
    
}
