//
//  AppDelegate+RecentlyDataPrepopulation.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

extension AppDelegate {

    func startPrepopulationProcessIfNecessary() {
        #if DEBUG || EXTERNAL
        NotificationCenter.default.addObserver(self, selector: #selector(prepopulate), name: .userSessionStarted, object: nil)
        #endif
    }

    @objc func prepopulate() {
        // Prepopulate if DEBUG (Convenience)
        // or External (Requirements)
        print(NSHomeDirectory())
        #if DEBUG || EXTERNAL

        // userSessionStarted is also called on restoreSession
        // Assume that when recentlyViewed/Searched is empty, it's the only time that
        // it's necessary to pre-populate.

        let session = UserSession.current
        if session.recentlyViewed.entities.isEmpty {
            if let recentlyViewedPath = Bundle.main.path(forResource: "RecentlyViewed", ofType: nil, inDirectory: "DemoPrepopulate") {

                let url = URL(fileURLWithPath: recentlyViewedPath)
                if let recentlyViewed = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [MPOLKitEntity] {
                    UserSession.current.recentlyViewed.add(recentlyViewed)
                }
            }
        }

        if session.recentlySearched.isEmpty {
            if let recentlySearchedPath = Bundle.main.path(forResource: "RecentlySearch", ofType: "json", inDirectory: "DemoPrepopulate") {

                let url = URL(fileURLWithPath: recentlySearchedPath)

                if let recentlySearchedData = try? Data(contentsOf: url), let recentlySearched = try? JSONDecoder().decode([Searchable].self, from: recentlySearchedData) {
                    UserSession.current.recentlySearched = recentlySearched
                }
            }
        }

        #endif
    }

}
