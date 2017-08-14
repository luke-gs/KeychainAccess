//
//  PersonOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

fileprivate enum FilterItem: Int {
    case type

    static let count = 1

    var title: String {
        switch self {
        case .type: return NSLocalizedString("Search Type", comment: "")
        }
    }
}

fileprivate enum SearchType: String, Pickable {
    case registration = "Registration"
    case vin          = "VIN"
    case engineNumber = "Engine number"

    var title: String? {
        return self.rawValue
    }

    var subtitle: String? {
        return nil
    }

    static var all: [SearchType] = [.registration, .vin, .engineNumber]
}

fileprivate class VehicleSearchOptions: SearchOptions {

    var type:    SearchType = .registration
    var states:  [ArchivedManifestEntry]?
    var makes:   [ArchivedManifestEntry]?
    var models:  [ArchivedManifestEntry]?

    // MARK: - Filters

    var numberOfOptions: Int {
        return FilterItem.count
    }

    func title(at index: Int) -> String {
        return FilterItem(rawValue: index)?.title ?? "-"
    }

    func value(at index: Int) -> String? {
        guard let filterItem = FilterItem(rawValue: index) else { return nil }

        switch filterItem {
        case .type:
            return type.title
        }
    }

    func defaultValue(at index: Int) -> String {
        return "Any"
    }
}

class VehicleSearchDataSource: SearchDataSource {
    
    let searchPlaceholder: NSAttributedString? = NSAttributedString(string: NSLocalizedString("eg. ABC123", comment: ""),
                                                                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
    
    //MARK: SearchDataSource
    var options: SearchOptions = VehicleSearchOptions()
    
    let registrationParser = QueryParser(parserDefinition: RegistrationParserDefinition(range: 1...9))
    let vinParser          = QueryParser(parserDefinition: VINParserDefinition(range: 10...17))
    let engineParser       = QueryParser(parserDefinition: EngineNumberParserDefinition(range: 10...20))
    
    weak var updatingDelegate: SearchDataSourceUpdating?

    var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    static var keyboardType: UIKeyboardType {
        return .asciiCapable
    }

    static var autoCapitalizationType: UITextAutocapitalizationType {
        return .words
    }

    func updateController(forFilterAt index: Int) -> UIViewController? {
        guard let item = FilterItem(rawValue: index) else { return nil }
        guard let options = options as? VehicleSearchOptions else { return nil }
        let viewController: UIViewController
        
        switch item {
        case .type:
            let searchTypes = SearchType.all

            let picker = PickerTableViewController(style: .plain, items: searchTypes)
            picker.selectedIndexes = searchTypes.indexes { $0 == options.type }
            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }

                options.type = searchTypes[selectedTypeIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            viewController = picker
        }
        viewController.title = item.title

        return PopoverNavigationController(rootViewController: viewController)
    }

    // MARK: - SearchResultViewModel
    
    func searchResultModel(for searchable: Searchable) -> SearchResultViewModelable? {
        guard let searchTerm = searchable.searchText else { return nil }
        
        let searchParams = VehicleSearchParameters(criteria: searchTerm)

        // Note: generate as many requests as required
        let request = VehicleSearchRequest(source: .mpol, request: searchParams)
        
        return EntitySummarySearchResultViewModel<Vehicle>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))
    }
    
    // MARK: - Validation passing
    
    func passValidation(for searchable: Searchable) -> String? {
        guard let searchTerm = searchable.searchText, let selectedType = searchable.options?[FilterItem.type.rawValue], let type = SearchType(rawValue: selectedType) else {
            return "Unsupported query."
        }
        
        do {
            _ = try parser(forType: type).parseString(query: searchTerm)
            print(parser(forType: type))
        } catch (let error) {
            if let error = error as? QueryParsingError {
                return error.message
            } else {
                return "Unexpected values have been entered. Refer to search help."
            }
        }
        
        return nil
    }
    
    // MARK: - Private
    
    private func parser(forType type: SearchType) -> QueryParser {
        switch type {
        case .registration: return self.registrationParser
        case .vin:          return self.vinParser
        case .engineNumber: return self.engineParser
        }
    }
}
