//
//  AlertReading.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public protocol AlertReading: SearchDataSource {
    var shouldReadAlerts: Bool { get set }
}
