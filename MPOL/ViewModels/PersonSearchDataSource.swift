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

class PersonSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate {

    static let searchableType = "Person"

    private let searchPlaceholder = NSAttributedString(string: NSLocalizedString("eg. Smith John K", comment: ""),
                                                       attributes: [
                                                        NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight),
                                                        NSForegroundColorAttributeName: UIColor.lightGray
        ])

    private var additionalSearchButtons: [UIButton] {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton(_:)), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        return [helpButton]
    }

    private var text: String? {
        didSet {
            navigationButton?.isEnabled = text?.characters.count ?? 0 > 0
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

    weak var updatingDelegate: SearchDataSourceUpdating?

    var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    // MARK: - Private

    @objc private func didTapHelpButton(_ button: UIButton) {
        (self.updatingDelegate as? UIViewController)?.present(AppScreen.help(type: .person))
    }

    private func generateResultModel(_ text: String?, completion: ((SearchResultViewModelable?, Error?) -> ())) {
        do {
            if let searchTerm = text {
                let definitions = self.definitionSelector.supportedDefinitions(for: searchTerm)
                if let definition = definitions.first {

                    let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                    var searchParameters: EntitySearchRequest<Person>?

                    if definition is PersonParserDefinition {
                        var dobSearch: String?

                        if let dateOfBirthString = personParserResults[PersonParserDefinition.DateOfBirthKey],
                            let dateOfBirth = PersonSearchDataSource.inputDateFormatter.date(from: dateOfBirthString) {
                            dobSearch =  PersonSearchDataSource.outputDateFormatter.string(from: dateOfBirth)
                        }

                        searchParameters = PersonSearchParameters(familyName: personParserResults[PersonParserDefinition.SurnameKey]!,
                                                                  givenName: personParserResults[PersonParserDefinition.GivenNameKey],
                                                                  middleNames: personParserResults[PersonParserDefinition.MiddleNamesKey],
                                                                  gender: personParserResults[PersonParserDefinition.GenderKey],
                                                                  dateOfBirth: dobSearch)
                    } else if definition is LicenceParserDefinition {
                        let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                        searchParameters = LicenceSearchParameters(licenceNumber: personParserResults[LicenceParserDefinition.licenceKey]!)
                    }

                    if let searchParameters = searchParameters {
                        // Note: generate as many requests as required
                        let request = PersonSearchRequest(source: .mpol, request: searchParameters)
                        let resultModel = EntitySummarySearchResultViewModel<Person>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))
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
                self.errorMessage = error.localizedDescription
            } else {
                // Generate Searchable
                let search = Searchable(text: text, options: nil, type: PersonSearchDataSource.searchableType)
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

}
