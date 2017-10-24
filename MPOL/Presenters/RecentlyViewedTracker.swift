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
                var recents = UserSession.current.recentlyViewed
                guard recents.first != entity else { return }
                
                for (index, oldEntity) in recents.enumerated() {
                    if oldEntity == entity {
                        recents.remove(at: index)
                        break
                    }
                }
                recents.insert(entity, at: 0)
                
                UserSession.current.recentlyViewed = recents
            default: break
            }
        }
    }

}
