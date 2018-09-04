//
//  AssetManager+SketchKit.swift
//  SketchKit
//
//  Created by Trent Fitzgibbon on 4/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreKit

extension AssetManager.BundlePriority {
    public static let sketchKit = AssetManager.BundlePriority(200)
}

extension AssetManager.ImageKey {
    public static let penStub = AssetManager.ImageKey("penStub")
    public static let penNib  = AssetManager.ImageKey("penNib")
    public static let rubber  = AssetManager.ImageKey("rubber")
}
