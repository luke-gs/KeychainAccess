//
//  Vehicle+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension Vehicle: EntitySummaryDisplayable {
    
    public var category: String? {
        return source?.localizedBadgeTitle
    }
    
    public var title: String? {
        return registration ?? NSLocalizedString("Registration Unknown", comment: "")
    }
    
    public var detail1: String? {
        return formattedYOMMakeModel()
    }
    
    public var detail2: String? {
        return bodyType
    }
    
    public var alertColor: UIColor? {
        return alertLevel?.color
    }
    
    public var badge: UInt {
        return actionCount
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        let imageName: String
        switch size {
        case .small:
            imageName = "iconEntityAutomotiveFilled"
        case .medium:
            imageName = "iconEntityAutomotive48Filled"
        case .large:
            imageName = "iconEntityAutomotive96Filled"
        }
        
        if let image = UIImage(named: imageName, in: .mpolKit, compatibleWith: nil) {
            return (image, .center)
        }
        
        return nil
    }
    
    private func formattedYOMMakeModel() -> String? {
        
        let components = [year, make, model].flatMap({$0})
        if components.isEmpty == false {
            return components.joined(separator: " ")
        }
        
        return nil
    }
    
}

