//
//  UIImage+EntityImages.swift
//  MPOLKit
//
//  Created by Rod Brown on 5/4/17.
//
//

import UIKit

extension UIImage {
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .entityPerson)")
    public static let personOutline = AssetManager.shared.image(forKey: .entityPerson)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .entityCar)")
    public static let carOutline = AssetManager.shared.image(forKey: .entityCar)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.image(forKey: .entityBuilding)")
    public static let buildingOutline = AssetManager.shared.image(forKey: .entityBuilding)!
    
}
