//
//  ClusterAnnotationView.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit
import Cluster

open class ClusterAnnotationView: MKAnnotationView {

    open let label = UILabel()

    open var color: UIColor = .gray {
        didSet {
            imageView.tintColor = color
        }
    }

    open override var annotation: MKAnnotation? {
        didSet {
            updateText()
        }
    }

    private let imageView = UIImageView()

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 60.0)
        centerOffset = CGPoint(x: 0.0, y: -26.0)

        imageView.image = AssetManager.shared.image(forKey: .pinCluster)
        imageView.frame = bounds

        label.frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 48.0)
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        
        imageView.tintColor = color

        addSubview(imageView)
        addSubview(label)

        updateText()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateText() {
        if let annotation = annotation as? ClusterAnnotation {
            label.text = "\(annotation.annotations.count)"
        } else {
            label.text = nil
        }
    }

}
