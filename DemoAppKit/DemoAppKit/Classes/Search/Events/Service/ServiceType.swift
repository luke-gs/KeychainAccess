//
//  ServiceType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public enum ServiceType: Int, OptionDisplayable, Codable {
    case email
    case mms
    case post

    public var title: String {
        switch self {
        case .email:
            return "Email"
        case .mms:
            return "MMS"
        case .post:
            return "Post"
        }
    }

    public var image: UIImage {
        switch self {
        case .email:
            return AssetManager.shared.image(forKey: AssetManager.ImageKey.commsEmail)!
        case .mms:
            return AssetManager.shared.image(forKey: AssetManager.ImageKey.commsDevice)!
        case .post:
            return AssetManager.shared.image(forKey: AssetManager.ImageKey.post)!
        }
    }
}
