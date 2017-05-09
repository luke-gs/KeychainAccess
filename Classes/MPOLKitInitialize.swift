//
//  MPOLKitInitialize.swift
//  Pods
//
//  Created by Rod Brown on 9/5/17.
//
//

import Foundation

// Temporary: Performs default setup for MPOLKit applications
public func MPOLKitInitialize() {
    
    // Access the keyboard input manager to start it managing all text entry.
    _ = KeyboardInputManager.shared
}
