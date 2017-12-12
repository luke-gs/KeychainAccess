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

    public func didPresent(_ presentable: Presentable, fromViewController: UIViewController, toViewController to: UIViewController) {
        if let presentable = presentable as? EntityScreen {
            switch presentable {
            case .entityDetails(let entity, _):
                let recentlyViewed = UserSession.current.recentlyViewed

                if recentlyViewed.contains(entity) {
                    recentlyViewed.remove(entity)
                }

                recentlyViewed.add(entity)
            default: break
            }
        }
    }

}
