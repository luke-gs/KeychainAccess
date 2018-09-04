//
//  MPOLKitInitialize.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/5/17.
//
//

import Foundation
import Lottie
import SketchKit

// Make life easier by importing dependent frameworks to all classes
// TODO: remove this and add explicit imports where needed
@_exported import CoreKit

extension AssetManager.BundlePriority {
    public static let patternKit = AssetManager.BundlePriority(300)
}

// Temporary: Performs default setup for MPOLKit applications
public func MPOLKitInitialize() {

    // Register bundles used by pattern kit containing assets
    AssetManager.shared.register(bundle: Bundle(for: SketchPen.self), priority: .sketchKit)
    AssetManager.shared.register(bundle: Bundle(for: FormBuilder.self), priority: .patternKit)

    // Access the keyboard input manager to start it managing all text entry.
    _ = KeyboardInputManager.shared
    
    // Preload MPOL animations
    LOTAnimationView.preloadMPOLAnimations()
}
