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
    
    var placeholderText: String {
        switch self {
        case .registration: return "eg. ABC123"
        case .vin:          return "eg. 1C4RDJAG9CC193202"
        case .engineNumber: return "eg. H22AM03737"
        }
    }
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
    
    private weak var viewController: UIViewController?
    
    var searchPlaceholder: NSAttributedString? {
        let text = (options as! VehicleSearchOptions).type.placeholderText
        return NSAttributedString(string: text,
                                  attributes: [
                                    NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight),
                                    NSForegroundColorAttributeName: UIColor.lightGray])
    }
    
    private(set) var additionalSearchFieldButtons: [UIButton]?
    
    // MARK: SearchDataSource
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
    
    init() {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton(_:)), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        additionalSearchFieldButtons = [helpButton]
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
            picker.selectionUpdateHandler = { [weak self, weak picker] (_, selectedIndexes) in
                guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }

                options.type = searchTypes[selectedTypeIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
                picker?.dismiss(animated: true, completion: nil)
            }
            viewController = picker
        }
        viewController.title = item.title

        return PopoverNavigationController(rootViewController: viewController)
    }

    // MARK: - SearchResultViewModel
    
    func searchResultModel(for searchable: Searchable) -> SearchResultViewModelable? {
        guard let searchTerm = searchable.searchText, let selectedType = searchable.options?[FilterItem.type.rawValue], let type = SearchType(rawValue: selectedType) else {
            return nil
        }
        
        let queryParser = parser(forType: type)
        let parserResults = try! queryParser.parseString(query: searchTerm)
        
        var searchParameters: EntitySearchRequest<Vehicle>?
        
        if queryParser === registrationParser {
            searchParameters = VehicleSearchParameters(registration: parserResults[RegistrationParserDefinition.registrationKey]!)
        } else if queryParser === vinParser {
            searchParameters = VehicleSearchParameters(vin: parserResults[VINParserDefinition.vinKey]!)
        } else if queryParser === engineParser {
            searchParameters = VehicleSearchParameters(engineNumber: parserResults[EngineNumberParserDefinition.engineNumberKey]!)
        }
        
        if let searchParameters = searchParameters {
            // Note: generate as many requests as required
            let request = VehicleSearchRequest(source: .mpol, request: searchParameters)
            return EntitySummarySearchResultViewModel<Vehicle>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))
        }
        
        return nil
    }
    
    // MARK: - Validation passing
    
    func passValidation(for searchable: Searchable) -> String? {
        guard let searchTerm = searchable.searchText, let selectedType = searchable.options?[FilterItem.type.rawValue], let type = SearchType(rawValue: selectedType) else {
            return "Unsupported query."
        }
        
        do {
            _ = try parser(forType: type).parseString(query: searchTerm)
            print(parser(forType: type))
        } catch let error {
            return error.localizedDescription
        }
        
        return nil
    }
    
    func setSelectedOptions(options: [Int : String]) {
        let vehicleOptions = self.options as! VehicleSearchOptions
        
        vehicleOptions.type = SearchType(rawValue: options[FilterItem.type.rawValue] ?? "") ?? .registration
    }
    
    func didBecomeActive(inViewController viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Private
    
    private func parser(forType type: SearchType) -> QueryParser {
        switch type {
        case .registration: return self.registrationParser
        case .vin:          return self.vinParser
        case .engineNumber: return self.engineParser
        }
    }
    
    @objc private func didTapHelpButton(_ button: UIButton) {
        // FIXME: - When the appropriate time comes please change it
        let helpViewController = UIViewController()
        helpViewController.title = "Vehicle Search Help"
        helpViewController.view.backgroundColor = .white
        self.viewController?.show(helpViewController, sender: nil)
    }
}
