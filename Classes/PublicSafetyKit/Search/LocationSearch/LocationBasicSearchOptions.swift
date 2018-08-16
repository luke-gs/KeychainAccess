//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation


public enum LocationBasicSearchResultType {
    case lookup
    case manual(title: String)
    case map(title: String)
    case currentLocation(title: String)

    var title: String {
        switch self {
        case .manual(let title):
            return title
        case .map(let title):
            return title
        case .currentLocation(let title):
            return title
        case .lookup:
            return "Lookup"
        }
    }

    public enum Builder {
        public static func manual(title: String? = nil) -> LocationBasicSearchResultType {
            return LocationBasicSearchResultType.manual(title: title ?? "Enter Manual Address")
        }
        public static func map(title: String? = nil) -> LocationBasicSearchResultType {
            return LocationBasicSearchResultType.map(title: title ?? "Search on Map")
        }
        public static func currentLocation(title: String? = nil) -> LocationBasicSearchResultType {
            return LocationBasicSearchResultType.currentLocation(title: title ?? "Search Current Location")
        }
    }

    public static var make: LocationBasicSearchResultType.Builder.Type {
        return LocationBasicSearchResultType.Builder.self
    }
}


/// Implementation of basic search options that allows results to be provided the client.
open class LocationBasicSearchOptions: SearchOptions {

    open var headerText: String? {
        return nil
    }

    open var results: [LookupResult] = []
    open var others: [LocationBasicSearchResultType]
    
    open weak var delegate: LocationBasicSearchOptionsDelegate?

    open var currentLocationActive: Bool = false

    open var numberOfOptions: Int {
        return results.count + others.count
    }

    public init(additionalOptions: [LocationBasicSearchResultType]) {
        others = additionalOptions
    }

    public func conditionalRequiredFields(for index: Int) -> [Int]? {
        return nil
    }

    open func title(at index: Int) -> String {
        let numberOfResults = results.count

        if numberOfResults > index {
            return results[index].title ?? NSLocalizedString("Unknown address", comment: "Location Search - when there is no address text")
        } else {
            let value = others[index - numberOfResults].title
            return value
        }
    }

    open func value(at index: Int) -> String? {
        let numberOfResults = results.count

        // Will trigger this block if the index is not one of the "others" options i.e. current location, search on map and advanced search
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
            return .action(image: AssetManager.shared.image(forKey: .eventLocation), buttonTitle: "Edit Address", buttonHandler: { [weak self] in
                guard let `self` = self else { return }
                let result = self.results[index]
                self.delegate?.locationBasicSearchOptions(self, didEditResult: result)
            })
        } else {
            let otherIndex = index - numberOfResults

            let other = others[otherIndex]
            switch other {
            case .currentLocation:
                return .action(image: AssetManager.shared.image(forKey: .eventLocation ), buttonTitle: nil, buttonHandler:nil)
            case .map:
                return .action(image: AssetManager.shared.image(forKey: .map), buttonTitle: nil, buttonHandler:nil)
            case .manual:
                return .action(image: AssetManager.shared.image(forKey: .edit), buttonTitle: nil, buttonHandler: nil)
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
