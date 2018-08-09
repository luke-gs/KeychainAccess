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
    case vehicleIdentifier
    case vehicleType

    static let count = 2

    var title: String {
        switch self {
        case .vehicleIdentifier: return NSLocalizedString("Search Type", comment: "")
        case .vehicleType: return NSLocalizedString("Vehicle Type", comment: "")
        }
    }
}

fileprivate enum VehicleIdentifier: String, Pickable {
    case registration = "Registration"
    case vin          = "VIN"
    case engineNumber = "Engine number"

    var title: String? {
        return self.rawValue
    }

    var subtitle: String? {
        return nil
    }

    static var all: [VehicleIdentifier] = [.registration, .vin, .engineNumber]

    var placeholderText: String {
        switch self {
        case .registration: return "eg. ABC123"
        case .vin: return "eg. 1C4RDJAG9CC193202"
        case .engineNumber: return "eg. H22AM03737"
        }
    }
}

fileprivate enum VehicleType: String, Pickable {
    case allVehicleTypes = ""
    case car = "Car"
    case motorcycle = "Motorcycle"
    case van = "Van"
    case truck = "Truck"
    case trailer = "Trailer"
    case vessel = "Vessel"

    var title: String? {
        if self == .allVehicleTypes {
            return "All"
        }
        return self.rawValue
    }

    var subtitle: String? {
        return nil
    }

    static var all: [VehicleType] = [.allVehicleTypes, .car, .motorcycle, .van, .truck, .trailer, .vessel]
}

fileprivate class VehicleSearchOptions: SearchOptions {
    var vehicleIdentifier: VehicleIdentifier = .registration
    var vehicleType: VehicleType = .allVehicleTypes

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
        case .vehicleIdentifier:
            return vehicleIdentifier.title
        case .vehicleType:
            return vehicleType.title
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

    func conditionalRequiredFields(for index: Int) -> [Int]? {
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
        helpButton.setImage(AssetManager.shared.image(forKey: .infoFilled), for: .normal)
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

            let text = (self.options as! VehicleSearchOptions).vehicleIdentifier.placeholderText
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

    let wildcardRegistrationParser = QueryParser(parserDefinition: RegistrationParserDefinition(range: 1...9))
    let wildcardVINParser          = QueryParser(parserDefinition: VINParserDefinition(range: 1...17))
    let wildcardEngineParser       = QueryParser(parserDefinition: EngineNumberParserDefinition(range: 1...20))

    weak var updatingDelegate: (SearchDataSourceUpdating & UIViewController)?

    var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        guard let item = FilterItem(rawValue: index) else { return .none }
        guard let options = options as? VehicleSearchOptions else { return .none }

        switch item {
        case .vehicleIdentifier:
            let searchTypes = VehicleIdentifier.all
            let picker = pickerController(forFilterAt: index,
                                          items: searchTypes,
                                          selectedIndexes: searchTypes.indexes { $0 == options.vehicleIdentifier },
                                          onSelect: { [weak self] (_, selectedIndexes) in
                                            guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }
                                            options.vehicleIdentifier = searchTypes[selectedTypeIndex]
                                            
                                            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyle)
            })

            return .options(controller: picker)
        case .vehicleType:
            let searchTypes = VehicleType.all
            let picker = pickerController(forFilterAt: index,
                                          items: searchTypes,
                                          selectedIndexes: searchTypes.indexes { $0 == options.vehicleType },
                                          onSelect: { [weak self] (_, selectedIndexes) in
                                            guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }
                                            options.vehicleType = searchTypes[selectedTypeIndex]

                                            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyle)
            })

            return .options(controller: picker)
        }
    }

    // MARK: - Private

    private func parser(forType type: VehicleIdentifier, text: String) -> QueryParser {
        let containsWildcard = text.contains("*")
        switch type {
        case .registration:
            if containsWildcard {
                return wildcardRegistrationParser
            }
            return registrationParser
        case .vin:
            if containsWildcard {
                return wildcardVINParser
            }
            return vinParser
        case .engineNumber:
            if containsWildcard {
                return wildcardEngineParser
            }
            return engineParser
        }
    }

    @objc private func didTapHelpButton(_ button: UIButton) {
        updatingDelegate?.present(EntityScreen.help(type: .vehicle))
    }

    private func generateResultModel(_ text: String?, completion: ((SearchResultViewModelable?, Error?) -> ())) {
        do {
            guard let searchTerm = text, let vehicleIdentifier = (options as? VehicleSearchOptions)?.vehicleIdentifier, let vehicleType = (options as? VehicleSearchOptions)?.vehicleType else {
                throw NSError(domain: "MPOL.VehicleSearchDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported query."])
            }

            let queryParser = parser(forType: vehicleIdentifier, text: searchTerm)
            let parserResults = try queryParser.parseString(query: searchTerm)

            var searchParameters: EntitySearchRequest<Vehicle>?

            let parserDefinition = queryParser.parser

            switch parserDefinition {
            case is RegistrationDefinitionType:
                searchParameters = VehicleSearchParameters(registration: parserResults[RegistrationParserDefinition.registrationKey]!, vehicleType: vehicleType.rawValue)
            case is VINDefinitionType:
                searchParameters = VehicleSearchParameters(vin: parserResults[VINParserDefinition.vinKey]!, vehicleType: vehicleType.rawValue)
            case is EngineNumberDefinitionType:
                searchParameters = VehicleSearchParameters(engineNumber: parserResults[EngineNumberParserDefinition.engineNumberKey]!, vehicleType: vehicleType.rawValue)
            default:
                #if DEBUG
                fatalError("No parser definition found. Ensure that all combinations are covered.")
                #endif
                break
            }


            if let searchParameters = searchParameters {
                // Note: generate as many requests as required
                let request = VehicleSearchRequest(source: .pscore, request: searchParameters)
                let rdaRequest = VehicleSearchRequest(source: .rda, request: searchParameters)
                
                let resultModel = EntitySummaryAlertsSearchResultViewModel<Vehicle>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request, rdaRequest]))

                resultModel.limitBehaviour = EntitySummarySearchResultViewModel.ResultLimitBehaviour.minimum(counts: [SearchResultStyle.grid: 4, SearchResultStyle.list: 3])
                resultModel.additionalBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonTapped(_:)))]
                resultModel.allowedStyles = [.list]
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
                let search = Searchable(text: text, options: options?.state(), type: VehicleSearchDataSource.searchableType, imageKey: AssetManager.ImageKey.entityCarSmall)
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
                vehicleOptions.vehicleIdentifier = VehicleIdentifier(rawValue: options[FilterItem.vehicleIdentifier.rawValue] ?? "") ?? .registration
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

    // MARK: - Add entity

    @objc private func handleAddButtonTapped(_ item: UIBarButtonItem) {
        updatingDelegate?.present(EntityScreen.createEntity(type: .vehicle))
    }

}
