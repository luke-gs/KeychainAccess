//
//  OrganisationSearchDataSource.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import ClientKit

fileprivate enum FilterItem: Int {
    case suburbFilter
    
    static let count = 1
    
    var title: String {
        switch self {
            case .suburbFilter: return NSLocalizedString("Suburb", comment: "")
        }
    }
}

fileprivate enum Suburb {
    case all
    // Individual State based on user input
    case individual(value: String)
    
    
    /// Initalize a suburb from a string
    /// Anything that doesnt match the title of all case
    /// and isnt empty is assumed to be an individual
    /// This is required based around our creation of searchables
    init(rawValue: String) {
        if rawValue == Suburb.all.title || rawValue.isEmpty {
            self = .all
        } else {
            self = .individual(value: rawValue)
        }
    }
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .individual(let value):
            return value
        }
    }
}

fileprivate class OrganisationSearchOptions: SearchOptions {
    var suburb: Suburb = .all
    
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
        case .suburbFilter:
            return suburb.title
        }
    }
    
    func defaultValue(at index: Int) -> String {
        return "All"
    }
    
    func type(at index: Int) -> SearchOptionType {
        return .text(configure: { textField in
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.returnKeyType = .done
        })
    }
    
    func errorMessage(at index: Int) -> String? {
        return nil
    }
    
    func conditionalRequiredFields(for index: Int) -> [Int]? {
        return nil
    }
}

class OrganisationSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate {
    
    static let searchableType = "Organisation"
    
    private var additionalSearchButtons: [UIButton] {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton(_:)), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .infoFilled), for: .normal)
        return [helpButton]
    }
    
    private let searchPlaceholder = NSAttributedString(string: NSLocalizedString("eg. Orion Central Bank", comment: ""),
                                                       attributes: [
                                                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light),
                                                        NSAttributedStringKey.foregroundColor: UIColor.lightGray
        ])
    
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
            
            textField.text                   = self.text
            textField.keyboardType           = .asciiCapable
            textField.autocapitalizationType = .words
            textField.autocorrectionType     = .no
            textField.attributedPlaceholder  = self.searchPlaceholder
            
            return self.additionalSearchButtons
            }, textHandler: self.searchTextDidChange, errorMessage: self.errorMessage)
    }
    
    let definitionSelector: QueryParserDefinitionSelector = {
        let definitionSelector = QueryParserDefinitionSelector()
        
        let formatter = NumberFormatter()
        let abnParser = ABNParserDefinition()
        definitionSelector.register(definition: abnParser, withValidation: abnParser.validateQuery)
        
        let acnParser = ACNParserDefinition()
        definitionSelector.register(definition: acnParser, withValidation: acnParser.validateQuery)
        
        definitionSelector.register(definition: OrganisationParserDefinition(), withValidation: { query in
            return query.isEmpty == false && formatter.number(from: query) == nil
        })
        
        return definitionSelector
    }()
    
    var options: SearchOptions? = OrganisationSearchOptions()
    
    var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
    var navigationButton: UIBarButtonItem?
    
    var updatingDelegate: (UIViewController & SearchDataSourceUpdating)?
    
    
    func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        guard let item = FilterItem(rawValue: index) else { return .none }
        switch item {
        case .suburbFilter:
            return .none
        }
    }
    
    func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool) {
        guard let options = options as? OrganisationSearchOptions else { return }
        guard let text = text else { return }
        if text.isEmpty {
            options.suburb = .all
        } else {
            options.suburb = .individual(value: text)
        }
    }
    
    // MARK: - Private
    
    @objc private func didTapHelpButton(_ button: UIButton) {
        updatingDelegate?.present(EntityScreen.help(type: .organisation))
    }
    
    private func generateResultModel(_ text: String?, completion: ((SearchResultViewModelable?, Error?) -> ())) {
        if let searchTerm = text {
            do {
                
                let definitions = self.definitionSelector.supportedDefinitions(for: searchTerm)
                if let definition = definitions.first {
                    
                    var searchParameters: EntitySearchRequest<Organisation>?
                    
                    if definition is OrganisationParserDefinition {
                        // Only apply suburb and name type to name searches
                        var suburb: String?
                        if let orgOptions = self.options as? OrganisationSearchOptions {
                            if case Suburb.individual(value: let val) = orgOptions.suburb {
                                suburb = val
                            }
                        }
                        
                        let organisationParserResults = try QueryParser(parserDefinition: OrganisationParserDefinition()).parseString(query: searchTerm)
                        searchParameters = OrganisationSearchParameters(name: organisationParserResults[OrganisationParserDefinition.NameKey],
                                                                        suburb: suburb)
                    } else if definition is ABNParserDefinition {
                        let organisationParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                        searchParameters = OrganisationSearchParameters(abn: organisationParserResults[ABNParserDefinition.ABNKey]!)
                    } else if definition is ACNParserDefinition {
                        let organisationParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                        searchParameters = OrganisationSearchParameters(acn: organisationParserResults[ACNParserDefinition.ACNKey]!)
                    }
                    if let searchParameters = searchParameters {
                        
                        // Note: generate as many requests as required
                        let request = OrganisationSearchRequest(source: .pscore, request: searchParameters)
                        let natRequest = OrganisationSearchRequest(source: .nat, request: searchParameters)
                        let rdaRequest = OrganisationSearchRequest(source: .rda, request: searchParameters)
                        
                        let resultModel = EntitySummaryAlertsSearchResultViewModel<Organisation>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request, natRequest, rdaRequest]))
                        resultModel.limitBehaviour = EntitySummarySearchResultViewModel.ResultLimitBehaviour.minimum(counts: [EntityDisplayStyle.grid: 4, EntityDisplayStyle.list: 3])
                    
                        completion(resultModel, nil)
                    }
                } else {
                   throw NSError(domain: "MPOL.OrganisationSearchDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported query."])
                }
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func prefill(withSearchable searchable: Searchable) -> Bool {
        let type = searchable.type
        
        if type == nil || type == OrganisationSearchDataSource.searchableType {
            text = searchable.text
            
            if let options = searchable.options {
                let organisationOptions = self.options as! OrganisationSearchOptions
                if let suburbOptionString = options[FilterItem.suburbFilter.rawValue] {
                    organisationOptions.suburb = Suburb(rawValue: suburbOptionString)
                }
            }
            
            return true
        }
        return false
    }
    
    private func performSearch() {
        generateResultModel(text) { (resultModel, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // Generate Searchable
                let search = Searchable(text: text, options: options?.state(), type: OrganisationSearchDataSource.searchableType, imageKey: AssetManager.ImageKey.entityBuilding)
                updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: resultModel)
            }
        }
    }
    
    // MARK: - Search text handling
    
    private func searchTextDidChange(_ text: String?, _ endEditing: Bool) {
        self.text = text
        
        if endEditing {
            performSearch()
        }
    }
    
    @objc private func searchButtonItemTapped() {
        performSearch()
    }
}
