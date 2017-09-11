//
//  RecentlyViewedTracker.swift
//  MPOL
//
//  Created by KGWH78 on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit


public class RecentlyViewedTracker: PresenterObserving {

    public private(set) var entities: [Entity] = []

    public func willPresent(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

    }

    public func didPresent(_ presentable: Presentable, fromViewController: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! EntityScreen

        switch presentable {
        case .entityDetails(let entity):
            entities.append(entity)
        default: break
        }
    }

}
