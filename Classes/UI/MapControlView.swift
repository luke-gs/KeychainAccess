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

    public let userLocationButton: UIButton
    public let infoButton: UIButton

    public var _userLocationTrackingMode: MKUserTrackingMode = .none

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
        let userLocationButton = UIButton(type: .custom)
        userLocationButton.setImage(AssetManager.shared.image(forKey: .mapUserLocation), for: .normal)
        self.userLocationButton = userLocationButton

        let infoButton = UIButton(type: .system)
        infoButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        self.infoButton = infoButton

        modeImageMapping = [
            // Tough luck if the image doesn't exist.
            .none: AssetManager.shared.image(forKey: .mapUserLocation)!,
            .follow: AssetManager.shared.image(forKey: .mapUserTracking)!,
            .followWithHeading: AssetManager.shared.image(forKey: .mapUserTrackingWithHeading)!
        ]

        super.init(buttons: [userLocationButton, infoButton])
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
                UIView.promiseAnimateKeyframes(withDuration: duration, delay: 0, options: [ .calculationModeCubic ], animations: {

                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                        self.userLocationButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                        self.userLocationButton.alpha = 0
                    })

                }).always {
                    self.userLocationButton.setImage(image, for: .normal)

                    UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut ], animations: {
                        self.userLocationButton.alpha = 1
                        self.userLocationButton.transform = .identity
                    }, completion: nil)
                }
            } else {
                UIView.transition(with: userLocationButton, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    self.userLocationButton.setImage(image, for: .normal)
                }, completion: nil)
            }

        } else {
            userLocationButton.setImage(image, for: .normal)
        }
    }

}
