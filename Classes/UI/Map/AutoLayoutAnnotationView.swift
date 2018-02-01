//
//  AutoLayoutAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// A `MKAnnotationView` subclass with a `contentView` which allows the use of Auto Layout
/// without weird layout issues that are most prominent in iOS 10
open class AutoLayoutAnnotationView: MKAnnotationView {

    open let contentView = UIView()
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if view != contentView {
            print("Warning in \(#file):\(#line): You should add views directly to `contentView` not `view`")
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        bounds = contentView.bounds
    }
    
    override open func prepareForReuse() {
        super.layoutSubviews()
        bounds = contentView.bounds
        
    }
  
}
