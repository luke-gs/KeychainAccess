//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit


open class LocationBasicSearchOptions: SearchOptions {
    open let headerText: String? = NSLocalizedString("SELECT AN ADDRESS TO CONTINUE", comment: "Location Search - type ahead results")

    open var locations: [Pickable] = []
    
    open weak var delegate: LocationBasicSearchOptionsDelegate?

    open var numberOfOptions: Int {
        return locations.count
    }

    open func title(at index: Int) -> String {
        return locations[index].title ?? NSLocalizedString("Unknown address", comment: "Location Search - when there is no address text")
    }

    open func value(at index: Int) -> String? {
        return locations[index].subtitle
    }

    open func defaultValue(at index: Int) -> String {
        return "Unknown"
    }
    
    open func errorMessage(at index: Int) -> String? {
        return nil
    }

    open func type(at index: Int) -> SearchOptionType {
        return .action(image: AssetManager.shared.image(forKey: .location), buttonTitle: "Edit Address", buttonHandler: { [weak self] in
            guard let `self` = self else { return }
            let address = self.locations[index]
            self.delegate?.locationBasicSearchOptions(self, didEditLocation: address)
        })
    }
    
    open func reset() {
        locations = []
    }
}

public protocol LocationBasicSearchOptionsDelegate: class {
    func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditLocation location: Pickable)
}
