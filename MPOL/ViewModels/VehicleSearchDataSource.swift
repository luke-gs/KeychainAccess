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
    case searchType, state, make, model

    static let count = 4

    var title: String {
        switch self {
        case .searchType: return NSLocalizedString("Search Type", comment: "")
        case .state:      return NSLocalizedString("State/s",  comment: "")
        case .make:       return NSLocalizedString("Make",     comment: "")
        case .model:      return NSLocalizedString("Model",    comment: "")
        }
    }
}

fileprivate enum SearchType: Int, Pickable {
    case vehicleRegistration

    var title: String? {
        switch self {
        case .vehicleRegistration: return NSLocalizedString("Vehicle Registration", comment: "")
        }
    }

    var subtitle: String? {
        return nil
    }

    static var all: [SearchType] = [.vehicleRegistration]
}

fileprivate class VehicleSearchOptions: SearchOptions {

    var searchType: SearchType = .vehicleRegistration
    var states:  [ArchivedManifestEntry]?
    var makes:   [ArchivedManifestEntry]?
    var models:  [ArchivedManifestEntry]?

    // MARK: - Filters

    var numberOfOptions: Int {
        // VicPol and QPS will not require these filters. Adjust this as
        // necessary for each client.
        return 0 // FilterItem.count
    }

    func title(at index: Int) -> String {
        return FilterItem(rawValue: index)?.title ?? "-"
    }

    func value(at index: Int) -> String? {
        guard let filterItem = FilterItem(rawValue: index) else { return nil }

        switch filterItem {
        case .searchType:
            return searchType.title
        default:
            return nil
        }
    }

    func defaultValue(at index: Int) -> String {
        return "Any"
    }
}

class VehicleSearchDataSource: SearchDataSource {
    private var internalEntities: [Vehicle]?

    //MARK: SearchDataSource
    var options: SearchOptions = VehicleSearchOptions()
    var entities: [MPOLKitEntity]? {
        get {
            return internalEntities
        }
        set {
            guard let entities = newValue as? [Vehicle] else { return }
            internalEntities = entities
        }
    }

    var sortedEntities: [MPOLKitEntity]? {
        guard let entities = entities else { return nil }

        let sortDescriptors = [NSSortDescriptor(key: "matchScore", ascending: false),
                               NSSortDescriptor(key: "surname", ascending: true),
                               NSSortDescriptor(key: "givenName", ascending: true)]

        let sorted = (entities as NSArray).sortedArray(using: sortDescriptors) as! [Vehicle]

        return sorted
    }

    var filteredEntities: [MPOLKitEntity]? {
        return nil
    }

    weak var updatingDelegate: SearchDataSourceUpdating?

    var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
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

    func updateController(forFilterAt index: Int) -> UIViewController? {
        guard let item = FilterItem(rawValue: index) else { return nil }
        guard let options = options as? VehicleSearchOptions else { return nil }
        let viewController: UIViewController

        switch item {
        case .searchType:
            let searchTypes = SearchType.all

            let picker = PickerTableViewController(style: .plain, items: searchTypes)
            picker.selectedIndexes = searchTypes.indexes { $0 == options.searchType }
            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }

                options.searchType = searchTypes[selectedTypeIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            viewController = picker
        case .state:
            let states = Manifest.shared.entries(for: .States) ?? []

            let picker = PickerTableViewController(style: .plain, items: states )
            picker.noItemTitle   = NSLocalizedString("Any", comment: "")

            let currentStates = Set(states.flatMap({ ArchivedManifestEntry(entry: $0).current() }))
            picker.selectedIndexes = states.indexes { currentStates.contains($0) }

            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self else { return }

                options.states = states[selectedIndexes].flatMap { ArchivedManifestEntry(entry: $0) }
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }

            viewController = picker
        case .make:
            let picker = PickerTableViewController(style: .plain, items: [ManifestEntry]())
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        case .model:
            let picker = PickerTableViewController(style: .plain, items: [ManifestEntry]())
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        }
        viewController.title = item.title

        return PopoverNavigationController(rootViewController: viewController)
    }

    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style) {
        guard let entity = self.sortedEntities?[indexPath.item] as? Vehicle else { return }

        cell.titleLabel.text    = entity.summary

        let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
        cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        cell.thumbnailView.configure(for: entity, size: .small)
        cell.alertColor       = entity.alertLevel?.color
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle

    }

    func decorateAlert(_ cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style) {
        guard let entity = self.filteredEntities?[indexPath.item] as? Vehicle else { return }

        cell.titleLabel.text    = entity.summary

        let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
        cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
        cell.thumbnailView.configure(for: entity, size: .small)
        cell.alertColor       = entity.alertLevel?.color
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle
    }

    func decorateList(_ cell: EntityListCollectionViewCell, at indexPath: IndexPath) {
        guard let entity = self.sortedEntities?[indexPath.item] as? Vehicle else { return }

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
//        guard let searchTerm = searchable.searchText else { return nil }
//        let request = VehicleSearchRequest()
//        let params = SearchParameters(criteria: searchTerm)
//        
//        return try request.searchOperation(forSource: LEAPSource.leap, params: params) { [weak self] entities, error in
//            self?.entities = entities
//            completion?(entities != nil, error)
//        }
        //TODO: New network stuff
    }
}
