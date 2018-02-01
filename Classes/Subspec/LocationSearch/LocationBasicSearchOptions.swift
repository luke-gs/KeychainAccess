//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation


public enum LocationBasicSearchResultType: String {
    case lookup
    case advance = "Advanced Search"
    case map = "Search on a Map"
    case currentLocation = "Current Location"
}

/// Implementation of basic search options that allows results to be provided the client.
open class LocationBasicSearchOptions: SearchOptions {
    public func conditionalRequiredFields(for index: Int) -> [Int]? {
        return nil
    }

    open var headerText: String? {
        return results.count > 0 ? NSLocalizedString("SELECT AN ADDRESS TO CONTINUE", comment: "Location Search - type ahead results") : NSLocalizedString("SEARCH OPTIONS", comment: "Location Search - others")
    }

    public init() {}

    open var results: [LookupResult] = []
    open var others: [LocationBasicSearchResultType] = [.currentLocation, .map, .advance]
    
    open weak var delegate: LocationBasicSearchOptionsDelegate?

    open var currentLocationActive: Bool = false

    open var numberOfOptions: Int {
        return results.count + others.count
    }

    open func title(at index: Int) -> String {
        let numberOfResults = results.count

        if numberOfResults > index {
            return results[index].title ?? NSLocalizedString("Unknown address", comment: "Location Search - when there is no address text")
        } else {
            let value = others[index - numberOfResults].rawValue

            // TODO: - Update to use megan's stuff
            if value == "Current Location" && currentLocationActive == false {
                return "NO CURRENT LOCATION"
            }

            return others[index - numberOfResults].rawValue
        }
    }

    open func value(at index: Int) -> String? {
        let numberOfResults = results.count

        if numberOfResults > index {
            return results[index].subtitle
        }

        return nil
    }

    open func defaultValue(at index: Int) -> String {
        return ""
    }
    
    open func errorMessage(at index: Int) -> String? {
        return nil
    }

    open func type(at index: Int) -> SearchOptionType {
        let numberOfResults = results.count

        if numberOfResults > index {
            return .action(image: AssetManager.shared.image(forKey: .location), buttonTitle: "Edit Address", buttonHandler: { [weak self] in
                guard let `self` = self else { return }
                let result = self.results[index]
                self.delegate?.locationBasicSearchOptions(self, didEditResult: result)
            })
        } else {
            let otherIndex = index - numberOfResults

            let other = others[otherIndex]
            switch other {
            case .currentLocation:
                return .action(image: AssetManager.shared.image(forKey: .mapUserLocation), buttonTitle: nil, buttonHandler:nil)
            case .map:
                return .action(image: AssetManager.shared.image(forKey: .generalLocation), buttonTitle: nil, buttonHandler:nil)
            case .advance:
                return .action(image: AssetManager.shared.image(forKey: .advancedSearch), buttonTitle: nil, buttonHandler: nil)
            case .lookup:
                return .picker
            }
        }
    }
    
    open func reset() {
        results = []
    }

    open func resultType(at index: Int) -> LocationBasicSearchResultType {
        let numberOfResults = results.count

        if numberOfResults > index {
            return .lookup
        } else {
            let otherIndex = index - numberOfResults
            return others[otherIndex]
        }
    }
}

public protocol LocationBasicSearchOptionsDelegate: class {
    func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditResult result: LookupResult)
}
