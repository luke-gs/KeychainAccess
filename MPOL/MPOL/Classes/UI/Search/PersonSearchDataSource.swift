//
//  PersonOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

class PersonSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate {

    static let searchableType = "Person"

    private let searchPlaceholder = NSAttributedString(string: NSLocalizedString("eg. Smith John K", comment: ""),
                                                       attributes: [
                                                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light),
                                                        NSAttributedStringKey.foregroundColor: UIColor.lightGray
        ])

    private var additionalSearchButtons: [UIButton] {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton(_:)), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .infoFilled), for: .normal)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let scanButton = UIButton(type: .system)
            scanButton.addTarget(self, action: #selector(didTapScanButton(_:)), for: .touchUpInside)
            scanButton.setImage(AssetManager.shared.image(forKey: .contentScan), for: .normal)

            return [scanButton, helpButton]
        }

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

            textField.text                   = self.text
            textField.keyboardType           = .asciiCapable
            textField.autocapitalizationType = .words
            textField.autocorrectionType     = .no
            textField.attributedPlaceholder  = self.searchPlaceholder

            return self.additionalSearchButtons
        }, textHandler: self.searchTextDidChange, errorMessage: self.errorMessage)
    }

    lazy var navigationButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(searchButtonItemTapped))

    var options: SearchOptions?

    let definitionSelector: QueryParserDefinitionSelector = {
        let definitionSelector = QueryParserDefinitionSelector()

        let formatter = NumberFormatter()

        definitionSelector.register(definition: LicenceParserDefinition(range: 2...10), withValidation: { query in
            return query.isEmpty == false && formatter.number(from: query) != nil
        })

        definitionSelector.register(definition: LicenceWildcardParserDefinition(range: 2...10), withValidation: { query in

            guard query.isEmpty == false && (query.range(of: "*") != nil || query.range(of: "?") != nil) else {
                return false
            }

            let queryWithoutWild = query.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "?", with: "")
            return formatter.number(from: queryWithoutWild) != nil
        })

        definitionSelector.register(definition: PersonParserDefinition(), withValidation: { query in
            return query.isEmpty == false && formatter.number(from: query) == nil
        })

        return definitionSelector
    }()

    static private var inputDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    static private var outputDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    weak var updatingDelegate: (SearchDataSourceUpdating & UIViewController)?

    var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    // MARK: - Private

    @objc private func didTapHelpButton(_ button: UIButton) {
        updatingDelegate?.present(EntityScreen.help(type: .person))
    }

    @objc private func didTapScanButton(_ button: UIButton) {
        updatingDelegate?.present(EntityScreen.scanner)
    }


    private func generateResultModel(_ text: String?, completion: ((SearchResultViewModelable?, Error?) -> ())) {
        do {
            if let searchTerm = text {
                let definitions = self.definitionSelector.supportedDefinitions(for: searchTerm)
                if let definition = definitions.first {

                    let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                    var searchParameters: EntitySearchRequest<Person>?

                    if definition is PersonParserDefinition {

                        searchParameters = PersonSearchParameters(familyName: personParserResults[PersonParserDefinition.SurnameKey]!,
                                                                  givenName: personParserResults[PersonParserDefinition.GivenNameKey],
                                                                  middleNames: personParserResults[PersonParserDefinition.MiddleNamesKey],
                                                                  gender: personParserResults[PersonParserDefinition.GenderKey],
                                                                  dateOfBirth: personParserResults[PersonParserDefinition.DateOfBirthKey],
                                                                  age: personParserResults[PersonParserDefinition.AgeRangeKey])

                    } else if definition is LicenceDefinitionType {
                        let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                        searchParameters = LicenceSearchParameters(licenceNumber: personParserResults[LicenceParserDefinition.licenceNumberKey]!)

                    }

                    if let searchParameters = searchParameters {
                        // Note: generate as many requests as required
                        let request = PersonSearchRequest(source: .pscore, request: searchParameters)
                        let natRequest = PersonSearchRequest(source: .nat, request: searchParameters)
                        let rdaRequest = PersonSearchRequest(source: .rda, request: searchParameters)

                        let resultModel = EntitySummaryAlertsSearchResultViewModel<Person>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request, natRequest, rdaRequest]))
                        resultModel.limitBehaviour = EntitySummarySearchResultViewModel.ResultLimitBehaviour.minimum(counts: [EntityDisplayStyle.grid: 4, EntityDisplayStyle.list: 3])
                        resultModel.additionalBarButtonItems = [UIBarButtonItem(image: AssetManager.shared.image(forKey: .add), style: .plain, target: self, action: #selector(handleAddButtonTapped(_:)))]
                        
                        completion(resultModel, nil)
                    }
                } else {
                    throw NSError(domain: "MPOL.PersonSearchDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported query."])
                }
            }
        } catch {
            completion(nil, error)
        }
    }

    private func performSearch() {
        generateResultModel(text) { (resultModel, error) in
            if let error = error {
                self.errorMessage = String.localizedStringWithFormat(AssetManager.shared.string(forKey: .searchInvalidTextError), "Person")
            } else {
                // Generate Searchable
                let search = Searchable(text: text, options: nil, type: PersonSearchDataSource.searchableType, imageKey: AssetManager.ImageKey.entityPerson)
                updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: resultModel)
            }
        }
    }

    func prefill(withSearchable searchable: Searchable) -> Bool {
        if searchable.type == nil || searchable.type == PersonSearchDataSource.searchableType {
            text = searchable.text

            return true
        }

        return false
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

    // MARK: - Add entity

    @objc private func handleAddButtonTapped(_ item: UIBarButtonItem) {
        updatingDelegate?.present(EntityScreen.createEntity(type: .person))
    }

}
