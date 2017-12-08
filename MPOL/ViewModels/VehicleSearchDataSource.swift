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
        case .vin: return "eg. 1C4RDJAG9CC193202"
        case .engineNumber: return "eg. H22AM03737"
        }
    }
}

fileprivate class VehicleSearchOptions: SearchOptions {
    var type: SearchType = .registration

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

    func type(at index: Int) -> SearchOptionType {
        return .picker
    }

    func errorMessage(at index: Int) -> String? {
        return nil
    }

    weak var delegate: VehicleSearchOptionsDelegate?
}

fileprivate protocol VehicleSearchOptionsDelegate: class {
    func vehicleSearchOptionsDidChangeType(_ options: VehicleSearchOptions)
}

class VehicleSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate {

    static let searchableType = "Vehicle"

    private var additionalSearchButtons: [UIButton] {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton(_:)), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        return [helpButton]
    }

    private var text: String? {
        didSet {
            navigationButton?.isEnabled = text?.count ?? 0 > 0
            errorMessage = nil
        }
    }

    private var errorMessage: String? {
        didSet {
            if oldValue != errorMessage {
                updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyleErrorMessage)
            }
        }
    }

    var searchStyle: SearchFieldStyle {
        return .search(configure: { [weak self] (textField) in
            guard let `self` = self else { return nil }

            let text = (self.options as! VehicleSearchOptions).type.placeholderText
            let placeholder = NSAttributedString(string: text, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray
                ])

            textField.text                   = self.text
            textField.keyboardType           = .asciiCapable
            textField.autocapitalizationType = .allCharacters
            textField.autocorrectionType     = .no
            textField.attributedPlaceholder  = placeholder

            return self.additionalSearchButtons
        }, textHandler: self.searchTextDidChange, errorMessage: self.errorMessage)
    }

    lazy var navigationButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(searchButtonItemTapped))


    // MARK: SearchDataSource
    var options: SearchOptions? = VehicleSearchOptions()

    let registrationParser = QueryParser(parserDefinition: RegistrationParserDefinition(range: 1...9))
    let vinParser          = QueryParser(parserDefinition: VINParserDefinition(range: 10...17))
    let engineParser       = QueryParser(parserDefinition: EngineNumberParserDefinition(range: 10...20))

    weak var updatingDelegate: SearchDataSourceUpdating?

    var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        guard let item = FilterItem(rawValue: index) else { return .none }
        guard let options = options as? VehicleSearchOptions else { return .none }

        switch item {
        case .type:
            let searchTypes = SearchType.all
            let picker = pickerController(forFilterAt: index,
                                          items: searchTypes,
                                          selectedIndexes: searchTypes.indexes { $0 == options.type },
                                          onSelect: { [weak self] (_, selectedIndexes) in
                                            guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }
                                            options.type = searchTypes[selectedTypeIndex]
                                            
                                            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyle)
            })

            return .options(controller: picker)
        }
    }

    // MARK: - Private

    private func parser(forType type: SearchType) -> QueryParser {
        switch type {
        case .registration: return self.registrationParser
        case .vin: return self.vinParser
        case .engineNumber: return self.engineParser
        }
    }

    @objc private func didTapHelpButton(_ button: UIButton) {
        (self.updatingDelegate as? UIViewController)?.present(EntityScreen.help(type: .vehicle))
    }

    private func generateResultModel(_ text: String?, completion: ((SearchResultViewModelable?, Error?) -> ())) {
        do {
            guard let searchTerm = text, let type = (options as? VehicleSearchOptions)?.type else {
                throw NSError(domain: "MPOL.VehicleSearchDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported query."])
            }

            let queryParser = parser(forType: type)
            let parserResults = try queryParser.parseString(query: searchTerm)

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
                let resultModel = EntitySummarySearchResultViewModel<Vehicle>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))

                completion(resultModel, nil)
            }
        } catch {
            completion(nil, error)
        }
    }

    private func performSearch() {
        generateResultModel(text) { (resultModel, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                let search = Searchable(text: text, options: options?.state(), type: VehicleSearchDataSource.searchableType)
                updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: resultModel)
            }
        }
    }

    func prefill(withSearchable searchable: Searchable) -> Bool {
        let type = searchable.type

        if type == nil || type == VehicleSearchDataSource.searchableType {
            text = searchable.text

            if let options = searchable.options {
                let vehicleOptions = self.options as! VehicleSearchOptions
                vehicleOptions.type = SearchType(rawValue: options[FilterItem.type.rawValue] ?? "") ?? .registration
            }

            return true
        }

        return false
    }

    @objc private func searchButtonItemTapped() {
        performSearch()
    }

    // MARK: - Search text handling

    private func searchTextDidChange(_ text: String?, _ endEditing: Bool) {
        self.text = text

        if endEditing {
            performSearch()
        }
    }

}
