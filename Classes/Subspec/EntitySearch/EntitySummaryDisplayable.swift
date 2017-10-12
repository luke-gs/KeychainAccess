//
//  EntitySummaryDisplayable.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol EntitySummaryDisplayable {

    init(_ entity: MPOLKitEntity)
    
    var category: String? { get }
    
    var title: String? { get }
    
    var detail1: String? { get }
    
    var detail2: String? { get }
    
    var alertColor: UIColor? { get }
    
    var badge: UInt { get }
    
    func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)?
}

public protocol EntitySummaryDecoratable {
    
    func decorate(with entitySummary: EntitySummaryDisplayable)
    
}

