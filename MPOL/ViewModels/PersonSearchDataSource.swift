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
    case searchType, state, gender, age

    static let count = 4

    var title: String {
        switch self {
        case .searchType: return NSLocalizedString("Search Type", comment: "")
        case .state:      return NSLocalizedString("State/s",  comment: "")
        case .gender:     return NSLocalizedString("Gender/s", comment: "")
        case .age:        return NSLocalizedString("Age",      comment: "")
        }
    }

    fileprivate var pickerTitle: String {
        switch self {
        case .searchType: return NSLocalizedString("Search Type", comment: "")
        case .state:      return NSLocalizedString("State/s",  comment: "")
        case .gender:     return NSLocalizedString("Gender/s", comment: "")
        case .age:        return NSLocalizedString("Age Range",      comment: "")
        }
    }
}

fileprivate enum SearchType: Int, Pickable {
    case name

    var title: String? {
        switch self {
        case .name: return NSLocalizedString("Name", comment: "")
        }
    }

    var subtitle: String? {
        return nil
    }

    static var all: [SearchType] = [.name]
}

fileprivate class PersonSearchOptions: SearchOptions {

    var searchType: SearchType = .name
    var states: [ArchivedManifestEntry]?
    var gender: Person.Gender?
    var ageRange: Range<Int>?

    var numberOfOptions: Int {
        return 0
    }

    func title(at index: Int) -> String {
        return FilterItem(rawValue: index)?.title ?? "-"
    }

    func value(at index: Int) -> String? {
        guard let filterItem = FilterItem(rawValue: index) else { return nil }

        switch filterItem {
        case .searchType:
            return searchType.title
        case .age:
            if let ageRange = ageRange {
                if ageRange.lowerBound == ageRange.upperBound {
                    return "\(ageRange.lowerBound)"
                }

                return "\(ageRange.lowerBound) - \(ageRange.upperBound)"
            }
            return nil
        case .gender:
            return gender?.description
        default:
            return nil
        }
    }

    func defaultValue(at index: Int) -> String {
        return "Any"
    }
}

class PersonSearchDataSource: SearchDataSource, NumberRangePickerDelegate {
    private weak var viewController: UIViewController?
    
    let searchPlaceholder: NSAttributedString? = NSAttributedString(string: NSLocalizedString("eg. Smith John K", comment: ""),
                                                                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
    
    private(set) var additionalSearchFieldButtons: [UIButton]?
    
    var options: SearchOptions = PersonSearchOptions()

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
    
    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    func updateController(forFilterAt index: Int) -> UIViewController? {
        guard let item = FilterItem(rawValue: index) else { return nil }
        guard let options = options as? PersonSearchOptions else { return nil }
        let viewController: UIViewController

        switch item {
        case .searchType:
            let values = SearchType.all
            let picker = PickerTableViewController(style: .plain, items: values)
            picker.selectedIndexes = values.indexes { $0 == options.searchType }
            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }

                options.searchType = values[selectedTypeIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            viewController = picker
        case .gender:
            let genders = Person.Gender.allCases
            let picker = PickerTableViewController(style: .plain, items: genders)
            picker.title = NSLocalizedString("Gender/s", comment: "")
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            picker.selectedIndexes = genders.indexes { $0 == options.gender }

            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self, let selectedGenderIndex = selectedIndexes.first else { return }

                options.gender = genders[selectedGenderIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }

            // TODO: Handle selection
            viewController = picker
        case .state:
            let states = Manifest.shared.entries(for: .States) ?? []

            let picker = PickerTableViewController(style: .plain, items: states)
            picker.noItemTitle = NSLocalizedString("Any", comment: "")

            let currentStates = Set(states.flatMap { ArchivedManifestEntry(entry: $0).current() })
            picker.selectedIndexes = states.indexes { currentStates.contains($0) }

            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self else { return }

                options.states = states[selectedIndexes].flatMap { ArchivedManifestEntry(entry: $0) }
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }

            viewController = picker
        case .age:
            let ageNumberPicker = NumberRangePickerViewController(min: 0, max: 100)
            ageNumberPicker.delegate = self
            ageNumberPicker.noRangeTitle = NSLocalizedString("Any Age", comment: "")

            if let ageRange = options.ageRange {
                ageNumberPicker.currentMinValue = ageRange.lowerBound
                ageNumberPicker.currentMaxValue = ageRange.upperBound
            } else {
                // Workaround:
                // Delay the update until the presentation UI is in place.
                // Reloading during selection causes bugs in UICollectionView.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    options.ageRange = Range<Int>(uncheckedBounds: (ageNumberPicker.currentMinValue, ageNumberPicker.currentMaxValue))
                    self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
                }
            }

            viewController = ageNumberPicker
        }
        viewController.title = item.pickerTitle

        return PopoverNavigationController(rootViewController: viewController)
    }

    // MARK: - Number range picker delegate

    func numberRangePicker(_ numberPicker: NumberRangePickerViewController, didUpdateMinValue minValue: Int, maxValue: Int) {
        guard let options = options as? PersonSearchOptions else { return }

        let newRange = Range<Int>(uncheckedBounds: (minValue, maxValue))
        if options.ageRange != newRange {
            options.ageRange = newRange
            updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
        }
    }
    
    func numberRangePickerDidSelectNoRange(_ picker: NumberRangePickerViewController) {
        guard let options = options as? PersonSearchOptions else { return }

        if options.ageRange != nil {
            options.ageRange = nil
            updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SearchResultViewModel
    
    func searchResultModel(for searchable: Searchable) -> SearchResultViewModelable? {
        do {
            guard let searchTerm = searchable.searchText else { return nil }

            if let definition = self.definitionSelector.supportedDefinitions(for: searchTerm).first {
                
                let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                var searchParameters: EntitySearchRequest<Person>?
                
                if definition is PersonParserDefinition {
                    var dobSearch: String?
                    
                    if let dateOfBirthString = personParserResults[PersonParserDefinition.DateOfBirthKey],
                        let dateOfBirth = PersonSearchDataSource.inputDateFormatter.date(from: dateOfBirthString) {
                        dobSearch =  PersonSearchDataSource.outputDateFormatter.string(from: dateOfBirth)
                    }
                    
                    searchParameters = PersonSearchParameters(familyName:   personParserResults[PersonParserDefinition.SurnameKey]!,
                                                              givenName:    personParserResults[PersonParserDefinition.GivenNameKey],
                                                              middleNames:  personParserResults[PersonParserDefinition.MiddleNamesKey],
                                                              gender:       personParserResults[PersonParserDefinition.GenderKey],
                                                              dateOfBirth:  dobSearch)
                } else if definition is LicenceParserDefinition {
                    let personParserResults = try QueryParser(parserDefinition: definition).parseString(query: searchTerm)
                    searchParameters = LicenceSearchParameters(licenceNumber: personParserResults[LicenceParserDefinition.licenceKey]!)
                }
                
                if let searchParameters = searchParameters {
                    // Note: generate as many requests as required
                    let request = PersonSearchRequest(source: .mpol, request: searchParameters)
                    return EntitySummarySearchResultViewModel<Person>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))
                }
            }
        } catch {
            
        }
        
        return nil
    }
    
    func didBecomeActive(inViewController viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Validation passing
    
    func passValidation(for searchable: Searchable) -> String? {
        do {
            if let searchTerm = searchable.searchText {
                let definitions = self.definitionSelector.supportedDefinitions(for: searchTerm)
                if definitions.count == 1 {
                    _ = try QueryParser(parserDefinition: definitions.first!).parseString(query: searchTerm)
                } else {
                    
                }
            }
        } catch let error {
            return error.localizedDescription
        }
        
        return nil
    }
 
    // MARK: - Private
    
    @objc private func didTapHelpButton(_ button: UIButton) {
        // FIXME: - When the appropriate time comes please change it
        let helpViewController = UIViewController()
        helpViewController.title = "Person Search Help"
        helpViewController.view.backgroundColor = .white
        self.viewController?.show(helpViewController, sender: nil)
    }
}


