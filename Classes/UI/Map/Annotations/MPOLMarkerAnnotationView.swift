//
//  MPOLMarkerAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 9/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// Replicates `MKMarkerAnnotationView` but with iOS 10 support
open class MPOLMarkerAnnotationView: MKAnnotationView {
    
    public enum Size {
        case regular
        case mini
        
        public var frameSize: CGSize {
            switch self {
            case .regular:
                return CGSize(width: 48, height: 60)
            case .mini:
                return CGSize(width: 30, height: 40)
            }
        }
        
        public var imageSize: CGSize {
            switch self {
            case .regular:
                return CGSize(width: 24, height: 24)
            case .mini:
                return CGSize(width: 20, height: 20)
            }
        }
        
        public var reuseIdentifier: String {
            switch self {
            case .regular:
                return "ResourceAnnotationViewRegularIdentifier"
            case .mini:
                return "ResourceAnnotationViewMiniIdentifier"
            }
        }
    }
    
    open var markerTintColor: UIColor = .gray {
        didSet {
            imageView.tintColor = markerTintColor
        }
    }
    
    open var glyphImage: UIImage? {
        didSet {
            glyphImageView.image = glyphImage
        }
    }
    
    open var glyphTintColor: UIColor? = .white {
        didSet {
            glyphImageView.tintColor = glyphTintColor
        }
    }
    
    private let imageView = UIImageView()
    private let glyphImageView = UIImageView()
    private let size: Size
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, size: Size) {
        self.size = size
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(origin: .zero, size: size.frameSize)
        centerOffset = CGPoint(x: 0.0, y: 4.0)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        imageView.image = AssetManager.shared.image(forKey: .pinCluster)
        imageView.frame = bounds
        
        imageView.tintColor = markerTintColor
        imageView.tintAdjustmentMode = .normal
        
        addSubview(imageView)
        
        glyphImageView.frame = CGRect(origin: .zero, size: size.imageSize)
        glyphImageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY - centerOffset.y)
        glyphImageView.contentMode = .scaleAspectFit
        glyphImageView.tintColor = glyphTintColor
        
        addSubview(glyphImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            var transform: CGAffineTransform = .identity
            if selected {
                transform = transform.scaledBy(x: 1.2, y: 1.2)
            }
            self.transform = transform
        })
    }
    
}
