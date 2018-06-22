//
//  GalleryButton.swift
//  MPOLKit
//
//  Created by Megan Efron on 13/3/18.
//

import UIKit

public class GalleryButton: UIControl {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .brightBlue
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add slight shadow
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        
        // Add gallery icon
        let icon = UIImageView(image: AssetManager.shared.image(forKey: .gallery))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .white
        addSubview(icon)
        
        // Create constraints
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor),
        
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
        ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make button a circle
        layer.cornerRadius = bounds.height / 2
    }

}
