//
// Created by KGWH78 on 17/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation
import Lottie


private let LottieDirectory = "Lottie"
private let LottieType      = "json"


public enum MPOLSpinnerStyle {
    case regular

    fileprivate var size: CGSize {
        switch self {
        case .regular: return CGSize(width: 50.0, height: 50.0)
        }
    }
}


public class MPOLSpinnerView: LOTAnimationView {

    static var fileURL: URL = Bundle.mpolKit.url(forResource: "spinner", withExtension: LottieType, subdirectory: LottieDirectory)!

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

        let cacheName = MPOLSpinnerView.fileURL.absoluteString
        var model = LOTAnimationCache.shared().animation(forKey: cacheName)

        // Load model if not already cached
        if model == nil {
            model = LOTAnimationView.loadMPOLAnimation(fileURL: MPOLSpinnerView.fileURL)
        }
        super.init(model: model, in: Bundle.mpolKit)

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
