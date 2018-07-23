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
    
    // MARK: - Customization
    
    /// Size for annotations
    public enum Size {
        case regular
        case mini
        
        public var frameSize: CGSize {
            switch self {
            case .regular:
                return CGSize(width: 68, height: 80)
            case .mini:
                return CGSize(width: 50, height: 60)
            }
        }

        public var pinFrameSize: CGSize {
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
    
    /// Whether to show the title only when the annotation is selected
    open var showsTitleOnSelectedOnly: Bool = true {
        didSet {
            updateTitleHidden()
        }
    }
    
    // MARK: - Views
    
    private let imageView = UIImageView()
    private let glyphImageView = UIImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Sizing
    private let size: Size
    private let titleSpacing: CGFloat = 15
    
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, size: Size) {
        self.size = size
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        centerOffset = CGPoint(x: 0.0, y: 4.0)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        imageView.image = AssetManager.shared.image(forKey: .pinCluster)
        imageView.frame = CGRect(origin: bounds.origin, size: size.pinFrameSize)
        
        imageView.tintColor = markerTintColor
        imageView.tintAdjustmentMode = .normal
        addSubview(imageView)
        
        glyphImageView.frame = CGRect(origin: .zero, size: size.imageSize)
        glyphImageView.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY - centerOffset.y)
        glyphImageView.contentMode = .scaleAspectFit
        glyphImageView.tintColor = glyphTintColor
        addSubview(glyphImageView)
        
        titleLabel.text = annotation?.title ?? "" // WTF Swift
        titleLabel.frame = CGRect(origin: CGPoint(x: 0, y: glyphImageView.frame.maxY + titleSpacing), size: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius  = 2
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale

        addSubview(titleLabel)
        updateTitleHidden()
    }
    
    private func updateTitleHidden() {
        titleLabel.isHidden = (showsTitleOnSelectedOnly && !isSelected)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let imageFrame = imageView.frame
        let titleSize = titleLabel.text?.sizing(withNumberOfLines: titleLabel.numberOfLines, font: titleLabel.font)
        let titleWidth = titleSize?.minimumWidth(compatibleWith: traitCollection) ?? 0
        let titleHeight = titleSize?.minimumHeight(inWidth: titleWidth, compatibleWith: traitCollection) ?? 0
        
        let height: CGFloat = imageFrame.height + titleHeight + titleSpacing
        
        frame = CGRect(origin: frame.origin, size: CGSize(width: max(imageFrame.width, titleWidth), height: height))
        
        // Layout views for frame
        imageView.center.x = frame.width / 2
        glyphImageView.center = CGPoint(x: imageView.frame.midX, y: imageView.frame.midY - centerOffset.y)
        titleLabel.frame.size = CGSize(width: titleWidth, height: titleHeight)
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
            self.updateTitleHidden()
        })
    }
    
}
