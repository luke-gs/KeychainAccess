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
        
        backgroundColor = .white
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: AssetManager.shared.image(forKey: .gallery))
        icon.translatesAutoresizingMaskIntoConstraints = true
        addSubview(icon)
        
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
