//
//  UIImage+EntityImages.swift
//  MPOLKit
//
//  Created by Rod Brown on 5/4/17.
//
//

import UIKit

extension UIImage {
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .entityPerson)")
    public static let personOutline = AssetManager.shared.image(for: .entityPerson)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .entityCar)")
    public static let carOutline = AssetManager.shared.image(for: .entityCar)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.image(for: .entityBuilding)")
    public static let buildingOutline = AssetManager.shared.image(for: .entityBuilding)!
    
}
