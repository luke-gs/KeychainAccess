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
            updatePinUI()
        }
    }

    open override var annotation: MKAnnotation? {
        didSet {
            updateText()
        }
    }

    private let detailView = RoundedRectLabel()
    private let iconImageView = UIImageView()
    private let backgroundImageView = UIImageView()
    private let innerCircleView = UIView()
    private let circleView = UIView()
    private let outerCircleView = UIView()

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 60.0)
        centerOffset = CGPoint(x: 0.0, y: 4.0)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)

        let center = CGPoint(x: 24.0, y: 24.5)
        let outerCircleViewDiameter: CGFloat = 38.0
        let innerCircleViewDiameter: CGFloat = 35.0
        let circleViewDiameter: CGFloat = 32.0

        backgroundImageView.image = AssetManager.shared.image(forKey: .pinLocation)
        backgroundImageView.frame = bounds

        outerCircleView.frame = CGRect(x: 0.0, y: 0.0, width: outerCircleViewDiameter, height: outerCircleViewDiameter)
        outerCircleView.center = center

        let outerCircleLayer = outerCircleView.layer
        outerCircleLayer.cornerRadius = outerCircleViewDiameter * 0.5
        outerCircleLayer.masksToBounds = true

        circleView.frame = CGRect(x: 0.0, y: 0.0, width: circleViewDiameter, height: circleViewDiameter)
        circleView.center = center

        let circleLayer = circleView.layer
        circleLayer.cornerRadius = circleViewDiameter * 0.5
        circleLayer.masksToBounds = true

        innerCircleView.frame = CGRect(x: 0.0, y: 0.0, width: innerCircleViewDiameter, height: innerCircleViewDiameter)
        innerCircleView.center = center

        let innerCircleLayer = innerCircleView.layer
        innerCircleLayer.cornerRadius = innerCircleViewDiameter * 0.5
        innerCircleLayer.masksToBounds = true

        iconImageView.image = AssetManager.shared.image(forKey: .eventLocation)
        iconImageView.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
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

        detailView.layoutMargins = UIEdgeInsets(top: 2.0, left: 8.0, bottom: 2.0, right: 8.0)
        detailView.alpha = 0.0

        addSubview(detailView)

        updateText()
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        detailView.alpha = selected ? 0.0 : 1.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            var transform: CGAffineTransform = .identity
            if selected {
                transform = transform.scaledBy(x: 1.2, y: 1.2)
            }
            self.transform = transform
            self.iconImageView.transform = transform.inverted()
            self.detailView.alpha = selected ? 1.0 : 0.0
        })
    }

    private func updateText() {
        detailView.text = annotation?.title ?? NSLocalizedString("Unknown", comment: "Location Pin - Unknown address")

        let size = detailView.sizeThatFits(CGSize(width: UILayoutFittingCompressedSize.width, height: 20.0))
        detailView.frame.size = CGSize(width: min(size.width, 200.0), height: 20.0)
        detailView.center = CGPoint(x: bounds.width * 0.5, y: bounds.maxY + 12)
    }
    
    private func updatePinUI() {
        if isSelected {
            backgroundImageView.tintColor = .white
            backgroundImageView.image = AssetManager.shared.image(forKey: .pinLocation)
            outerCircleView.backgroundColor = borderColor
            circleView.backgroundColor = .white
            innerCircleView.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.843, blue: 0.850, alpha: 1.0)
            iconImageView.tintColor = borderColor
        } else {
            backgroundImageView.tintColor = borderColor
            backgroundImageView.image = AssetManager.shared.image(forKey: .pinDefault)
            outerCircleView.backgroundColor = .clear
            innerCircleView.backgroundColor = borderColor
            circleView.backgroundColor = borderColor
            iconImageView.tintColor = .black
        }
    }

}
