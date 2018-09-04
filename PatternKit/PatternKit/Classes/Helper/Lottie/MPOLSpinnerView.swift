//
// Created by KGWH78 on 17/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation
import Lottie

public enum MPOLSpinnerStyle {
    case regular
    case large

    fileprivate var size: CGSize {
        switch self {
        case .regular: return CGSize(width: 50.0, height: 50.0)
        case .large: return CGSize(width: 64.0, height: 64.0)
        }
    }
}

public class MPOLSpinnerView: LOTAnimationView {

    public let style: MPOLSpinnerStyle

    public var color: UIColor? {
        didSet {
            setValue(color ?? .clear, forKeypath: "Shape Layer 1.small_circle.Stroke 1.Color", atFrame: 0)
            setValue(color ?? .clear, forKeypath: "Shape Layer 1.big_circle.Stroke 1.Color", atFrame: 0)
        }
    }

    /// Initialize a spinner view
    ///
    /// - Parameters:
    ///   - style: The spinner style.
    ///   - color: The color. Default to white
    public init(style: MPOLSpinnerStyle = .regular, color: UIColor? = .white) {
        self.style = style

        let fileURL = AssetManager.shared.resource(forKey: .animatedSpinner)!
        let cacheName = fileURL.absoluteString
        var model = LOTAnimationCache.shared().animation(forKey: cacheName)

        // Load model if not already cached
        if model == nil {
            model = LOTAnimationView.loadMPOLAnimation(fileURL: fileURL)
        }
        super.init(model: model, in: nil)

        loopAnimation = true
        frame = CGRect(origin: .zero, size: style.size)

        defer {
            self.color = color
        }
    }

    override open var intrinsicContentSize: CGSize {
        return style.size
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("MPOLSpinnerView does not support NSCoding.")
    }

}
