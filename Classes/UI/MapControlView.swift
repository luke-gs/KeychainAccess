//
//  MapControlView.swift
//  MPOLKit
//
//  Created by Herli Halim on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public class MapControlView: ButtonStackView {

    public let locateButton: UIButton
    public let optionButton: UIButton

    private var _userLocationTrackingMode: MKUserTrackingMode = .none

    public var userLocationTrackingMode: MKUserTrackingMode {
        get {
            return _userLocationTrackingMode
        }
        set {
            setUserLocationTrackingMode(newValue, animated: false)
        }
    }

    private var modeImageMapping: [MKUserTrackingMode: UIImage]

    public init() {
        let locateButton = UIButton(type: .system)
        locateButton.setImage(AssetManager.shared.image(forKey: .mapUserLocation), for: .normal)
        self.locateButton = locateButton

        let optionButton = UIButton(type: .system)
        optionButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        self.optionButton = optionButton

        modeImageMapping = [
            // Tough luck if the image doesn't exist.
            .none: AssetManager.shared.image(forKey: .mapUserLocation)!,
            .follow: AssetManager.shared.image(forKey: .mapUserTracking)!,
            .followWithHeading: AssetManager.shared.image(forKey: .mapUserTrackingWithHeading)!
        ]

        super.init(buttons: [locateButton, optionButton])
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public func setImage(_ image: UIImage, for userLocationTrackingMode: MKUserTrackingMode) {
        modeImageMapping[userLocationTrackingMode] = image
    }

    public func setUserLocationTrackingMode(_ mode: MKUserTrackingMode, animated: Bool) {

        guard mode != _userLocationTrackingMode else {
            return
        }

        let previous = _userLocationTrackingMode

        _userLocationTrackingMode = mode
        let image = modeImageMapping[mode]

        if animated {

            let duration = 0.15
            // .followWithHeading has different kind of image, so make it fancier, slightly.
            if mode == .followWithHeading || previous == .followWithHeading {
                let locateButton = self.locateButton
                UIView.promiseAnimateKeyframes(withDuration: duration, delay: 0, options: [ .calculationModeCubic ], animations: {

                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                        locateButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                        locateButton.alpha = 0
                    })

                }).always {
                    locateButton.setImage(image, for: .normal)

                    UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut ], animations: {
                        locateButton.alpha = 1
                        locateButton.transform = .identity
                    }, completion: nil)
                }
            } else {
                UIView.transition(with: locateButton, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    self.locateButton.setImage(image, for: .normal)
                }, completion: nil)
            }

        } else {
            locateButton.setImage(image, for: .normal)
        }
    }

}
