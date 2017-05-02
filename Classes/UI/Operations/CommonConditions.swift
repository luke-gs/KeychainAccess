//
//  CommonConditions.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A type to describe alerts in general for use with `MutuallyExclusiveCondition<T>`.
public enum Alert { }


/// A condition describing that the targeted operation may present an alert,
/// and cannot be used with other operations that present alerts.
public typealias AlertExclusiveCondition = MutuallyExclusiveCondition<Alert>


/// A condition describing that the targeted operation affects the view
/// controller hierarchy and cannot be used with other operations that do this also.
public typealias ViewControllerExclusiveCondition = MutuallyExclusiveCondition<UIViewController>
