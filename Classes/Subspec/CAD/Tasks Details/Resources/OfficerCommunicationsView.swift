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

    public let messageButton = UIButton(frame: .zero)
    public let callButton = UIButton(frame: .zero)
    public let videoButton = UIButton(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: Get real image from creative (waiting on exportable...)
        messageButton.setImage(AssetManager.shared.image(forKey: .email), for: .normal)
        messageButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)
        
        callButton.setImage(AssetManager.shared.image(forKey: .audioCall), for: .normal)
        callButton.contentMode = .scaleAspectFit
        callButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)
        
        videoButton.setImage(AssetManager.shared.image(forKey: .videoCall), for: .normal)
        videoButton.tintColor = #colorLiteral(red: 0, green: 0.4802979827, blue: 0.9984222054, alpha: 1)

        stackView = UIStackView(arrangedSubviews: [messageButton, callButton, videoButton])
        
        stackView.spacing = 24
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

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
