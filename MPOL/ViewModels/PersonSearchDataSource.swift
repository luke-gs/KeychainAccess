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

    let searchPlaceholder: NSAttributedString? = NSAttributedString(string: NSLocalizedString("eg. Smith John K", comment: ""),
                                                                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
    
    var options: SearchOptions = PersonSearchOptions()
    let parser: QueryParser<PersonParserDefinition> = QueryParser(parserDefinition: PersonParserDefinition())

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

            let picker = PickerTableViewController(style: .plain, items: states )
            picker.noItemTitle = NSLocalizedString("Any", comment: "")

            let currentStates = Set(states.flatMap({ ArchivedManifestEntry(entry: $0).current() }))
            picker.selectedIndexes = states.indexes { currentStates.contains($0) }

            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self else { return }

                options.states = states[selectedIndexes].flatMap { ArchivedManifestEntry(entry: $0) }
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }

            viewController = picker
        case .age:
            let ageNumberPicker = NumberRangePickerViewController(min:0, max: 100)
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
            
            let parsingResults = try parser.parseString(query: searchTerm)
            let dobSearch: String?
            
            if let dateOfBirthString = parsingResults[PersonParserDefinition.DateOfBirthKey],
                let dateOfBirth = PersonSearchDataSource.inputDateFormatter.date(from: dateOfBirthString) {
                dobSearch =  PersonSearchDataSource.outputDateFormatter.string(from: dateOfBirth)
            } else {
                dobSearch = nil
            }
            
            let searchParams = PersonSearchParameters(familyName:   parsingResults[PersonParserDefinition.SurnameKey]!,
                                                      givenName:    parsingResults[PersonParserDefinition.GivenNameKey],
                                                      middleNames:  parsingResults[PersonParserDefinition.MiddleNamesKey],
                                                      gender:       parsingResults[PersonParserDefinition.GenderKey],
                                                      dateOfBirth:  dobSearch)
            
            // Note: generate as many requests as required
            let request = PersonSearchRequest(source: .mpol, request: searchParams)
            
            return EntitySummarySearchResultViewModel<Person>(title: searchTerm, aggregatedSearch: AggregatedSearch(requests: [request]))
        } catch {
            
        }
        
        return nil
    }
    
    // MARK: - Validation passing
    
    func passValidation(for searchable: Searchable) -> String? {
        do {
            if let searchTerm = searchable.searchText {
                try parser.parseString(query: searchTerm)
            }
            
        } catch (let error) {
            let message: String
            
            switch error {
            case QueryParserError.requiredValueNotFound(let key):
                message = "Couldn't find value for required \(key). Refer to search help."
            case QueryParserError.additionalTokenFound:
                message = "Too many values have been entered. Refer to search help."
            case QueryParserError.multipleTokenDefinitions:
                // If this case is thrown it means the writer of the parser definition class
                // has defines two token definitions with the same key
                fatalError()
            case QueryParserError.typeNotFound(let token):
                message = "Unidentified value '\(token)' found. Refer to search help."
            case PersonParserError.surnameIsNotFirst(let surname):
                message = "Potential Surname '\(surname) found. Surname must be first. Refer to search help."
            case PersonParserError.surnameExceedsMaxLength(let surname, let maxLength):
                message = "Surname '\(surname) exceeds maximum length of \(maxLength) characters."
            case PersonParserError.givenNameExceedsMaxLength(let givenName, let maxLength):
                message = "Given name '\(givenName)' exceeds maximum length of \(maxLength) characters."
            case PersonParserError.middleNameExistsWithoutGivenName(let middleName):
                message = "Middle name '\(middleName)' exists without a given name."
            case PersonParserError.middleNamesExceedsMaxLength(let middleName, let maxLength):
                message = "Middle name '\(middleName)' exceeds maximum length of \(maxLength) characters."
            case PersonParserError.ageGapWrongOrder(let ageGap):
                message = "Age gap '\(ageGap)' in wrong order."
            case PersonParserError.nameMatchesGenderType(let gender):
                message = "Gender '\(gender) is invalid"
            case PersonParserError.dobInvalidValues(let dob):
                message = "'\(dob)'is not a recognised DOB. Please ensure date is valid."
            case PersonParserError.dobDateOutOfBounds(let dob):
                message = "'\(dob)' must be a past date."
            default:
                message = "Unexpected values have been entered. Refer to search help."
            }
            
            return message
        }
        
        return nil
    }
}
