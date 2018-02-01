//
//  PinAnnotationView.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit

open class PinAnnotationView: MKAnnotationView {

    private let imageView = UIImageView()

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 60.0)
        centerOffset = CGPoint(x: 0.0, y: 4.0)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)

        imageView.image = AssetManager.shared.image(forKey: .pinDefault)
        imageView.frame = bounds

        addSubview(imageView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
