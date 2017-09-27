//
//  MapImageButton.swift
//  MPOLKit
//
//  Created by Kyle May on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A button with an image to be presented over the top of a MKMapView
open class MapImageButton: UIControl {
    
    private let imageMargin: CGFloat = 13
    
    private var imageView: UIImageView!

    /// An image to display in the center of the button
    open var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { [unowned self] in
                self.imageView.alpha = self.isHighlighted ? 0.5 : 1
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.9845920205, green: 0.9781416059, blue: 0.9719238877, alpha: 1)
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 8
        layer.shadowOpacity = 1
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: imageMargin),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -imageMargin),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: imageMargin),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -imageMargin),
        ])
    }
    
    public convenience init(frame: CGRect = .zero, image: UIImage? = nil) {
        self.init(frame: frame)
        self.image = image
        imageView.image = image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
