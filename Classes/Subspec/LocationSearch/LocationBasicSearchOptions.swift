//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation


/// Implementation of basic search options that allows results to be provided the client.
open class LocationBasicSearchOptions: SearchOptions {
    open let headerText: String? = NSLocalizedString("SELECT AN ADDRESS TO CONTINUE", comment: "Location Search - type ahead results")

    open var results: [LookupResult] = []
    
    open weak var delegate: LocationBasicSearchOptionsDelegate?

    open var numberOfOptions: Int {
        return results.count
    }

    open func title(at index: Int) -> String {
        return results[index].title ?? NSLocalizedString("Unknown address", comment: "Location Search - when there is no address text")
    }

    open func value(at index: Int) -> String? {
        return results[index].subtitle
    }

    open func defaultValue(at index: Int) -> String {
        return ""
    }
    
    open func errorMessage(at index: Int) -> String? {
        return nil
    }

    open func type(at index: Int) -> SearchOptionType {
        return .action(image: AssetManager.shared.image(forKey: .location), buttonTitle: "Edit Address", buttonHandler: { [weak self] in
            guard let `self` = self else { return }
            let result = self.results[index]
            self.delegate?.locationBasicSearchOptions(self, didEditResult: result)
        })
    }
    
    open func reset() {
        results = []
    }
}

public protocol LocationBasicSearchOptionsDelegate: class {
    func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditResult result: LookupResult)
}
