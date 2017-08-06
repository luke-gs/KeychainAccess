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
        // VicPol and QPS will not require these filters. Adjust this as
        // necessary for each client.
        return 0
//            return FilterItem.count
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

    private var internalEntities: [Person]?

    var entities: [MPOLKitEntity]? {
        get {
            return internalEntities
        }
        set {
            guard let entities = newValue as? [Person] else { return }
            internalEntities = entities
        }
    }

    var sortedEntities: [MPOLKitEntity]? {
        guard let entities = entities else { return nil }

        let sortDescriptors = [NSSortDescriptor(key: "matchScore", ascending: false),
                               NSSortDescriptor(key: "surname", ascending: true),
                               NSSortDescriptor(key: "givenName", ascending: true)]

        let sorted = (entities as NSArray).sortedArray(using: sortDescriptors) as! [Person]

        return sorted
    }

    var filteredEntities: [MPOLKitEntity]? {
        let filtered = internalEntities?.filter({ return ($0.alertLevel != nil && $0.alertLevel!.rawValue > 0) }).sorted(by: { (entity1, entity2) -> Bool in
            let alertLevel1 = entity1.alertLevel?.rawValue ?? 0
            let alertLevel2 = entity2.alertLevel?.rawValue ?? 0

            return alertLevel1 > alertLevel2
        })

        return filtered
    }

    weak var updatingDelegate: SearchDataSourceUpdating?

    func supports(_ request: SearchRequest) -> Bool {
        return request is PersonSearchRequest
    }

    var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    var localizedSourceBadgeTitle: String {
        return NSLocalizedString("LEAP", bundle: .mpolKit, comment: "")
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

    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style) {
        guard let entity = self.sortedEntities?[indexPath.item] as? Person else { return }

        cell.titleLabel.text    = entity.summary

        let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
        cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        cell.thumbnailView.configure(for: entity, size: .small)
        cell.alertColor       = entity.alertLevel?.color
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle

    }

    func decorateAlert(_ cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style) {
        guard let entity = self.filteredEntities?[indexPath.item] as? Person else { return }

        cell.titleLabel.text    = entity.summary

        let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
        cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        cell.thumbnailView.configure(for: entity, size: .small)
        cell.alertColor       = entity.alertLevel?.color
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle
    }

    func decorateList(_ cell: EntityListCollectionViewCell, at indexPath: IndexPath) {
        guard let entity = self.sortedEntities?[indexPath.item] as? Person else { return }

        cell.titleLabel.text    = entity.summary

        let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
        cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        cell.thumbnailView.configure(for: entity, size: .small)
        cell.alertColor       = entity.alertLevel?.color
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle
    }

    func searchOperation(searchable: Searchable, completion: ((_ success: Bool, _ error: Error?)->())?) throws
    {
        guard let searchTerm = searchable.searchText else { return }
        let request = PersonSearchRequest()

        let parsingResults = try parser.parseString(query: searchTerm)
        let dobSearch: String?

        if let dateOfBirthString = parsingResults[PersonParserDefinition.DateOfBirthKey],
            let dateOfBirth = PersonSearchDataSource.inputDateFormatter.date(from: dateOfBirthString) {
            dobSearch =  PersonSearchDataSource.outputDateFormatter.string(from: dateOfBirth)
        } else {
            dobSearch = nil
        }

//        let searchParams = PersonSearchParameters(surname:      parsingResults[PersonParserDefinition.SurnameKey]!,
//                                                  givenName:    parsingResults[PersonParserDefinition.GivenNameKey],
//                                                  middleNames:  parsingResults[PersonParserDefinition.MiddleNamesKey],
//                                                  gender:       parsingResults[PersonParserDefinition.GenderKey],
//                                                  dateOfBirth:  dobSearch,
//                                                  ageGap:       parsingResults[PersonParserDefinition.AgeGapKey])
//
//
//        return try request.searchOperation(forSource: LEAPSource.leap, params: searchParams) { [weak self] entities, error in
//            self?.entities = entities
//            completion?(entities != nil, error)
//        }
        //TODO: New network stuff
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
    
}
