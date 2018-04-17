//
//  SearchActivitySimplifier.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 17/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Extension to simplify launching search activities
extension SearchActivity {

    public func launch() {
        let launcher = AnyActivityLauncher(scheme: SEARCH_APP_SCHEME)
        do {
            let wrap = AnyActivity(self)
            try launcher.launch(wrap, using: AppURLNavigator.default)
        } catch {
            AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Failed to open app", comment: ""))
        }
    }
}
