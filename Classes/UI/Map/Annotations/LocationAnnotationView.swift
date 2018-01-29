//
//  LocationAnnotationView.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit

open class LocationAnnotationView: MKAnnotationView {

    open var borderColor = UIColor(displayP3Red: 0.337, green: 0.337, blue: 0.384, alpha: 1.0) {
        didSet {
            outerCircleView.backgroundColor = borderColor
        }
    }

    private let iconImageView = UIImageView()
    private let backgroundImageView = UIImageView()
    private let innerCircleView = UIView()
    private let circleView = UIView()
    private let outerCircleView = UIView()

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 60.0)
        centerOffset = CGPoint(x: 0.0, y: -26.0)

        let center = CGPoint(x: 24.0, y: 24.5)

        backgroundImageView.image = AssetManager.shared.image(forKey: .pinLocation)
        backgroundImageView.frame = bounds

        outerCircleView.frame = CGRect(x: 0.0, y: 0.0, width: 36.0, height: 36.0)
        outerCircleView.center = center

        let outerCircleLayer = outerCircleView.layer
        outerCircleLayer.cornerRadius = 18.0
        outerCircleLayer.masksToBounds = true

        circleView.frame = CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0)
        circleView.center = center

        let circleLayer = circleView.layer
        circleLayer.cornerRadius = 16.0
        circleLayer.masksToBounds = true

        innerCircleView.frame = CGRect(x: 0.0, y: 0.0, width: 28.0, height: 28.0)
        innerCircleView.center = center

        let innerCircleLayer = innerCircleView.layer
        innerCircleLayer.cornerRadius = 14.0
        innerCircleLayer.masksToBounds = true

        iconImageView.image = AssetManager.shared.image(forKey: .location)
        iconImageView.frame = CGRect(x: 0.0, y: 0.0, width: 16.0, height: 16.0)
        iconImageView.center = center
        iconImageView.contentMode = .scaleAspectFit

        addSubview(backgroundImageView)
        addSubview(outerCircleView)
        addSubview(circleView)
        addSubview(innerCircleView)
        addSubview(iconImageView)

        outerCircleView.backgroundColor = borderColor
        circleView.backgroundColor = .white
        innerCircleView.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.843, blue: 0.850, alpha: 1.0)
        iconImageView.tintColor = UIColor(displayP3Red: 0.337, green: 0.337, blue: 0.3843, alpha: 1.0)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
