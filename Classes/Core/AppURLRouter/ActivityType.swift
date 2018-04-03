//
//  ActivityType.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol ActivityType: Parameterisable {
    var name: String { get }
}

public protocol ActivityLauncherType {

    associatedtype Activity: ActivityType

    func launch(_ activity: Activity, using navigator: AppURLNavigator) throws

}
