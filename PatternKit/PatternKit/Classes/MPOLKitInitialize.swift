//
//  MPOLKitInitialize.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/5/17.
//
//

import Foundation
import Lottie

// Make life easier by importing dependent frameworks to all classes
// TODO: remove this and add explicit imports where needed
@_exported import CoreKit

// Temporary: Performs default setup for MPOLKit applications
public func MPOLKitInitialize() {

    // Use resources from this bundle by default
    AssetManager.defaultBundle = Bundle(for: FormBuilder.self)
        
    // Access the keyboard input manager to start it managing all text entry.
    _ = KeyboardInputManager.shared
    
    // Preload MPOL animations
    LOTAnimationView.preloadMPOLAnimations()
}
