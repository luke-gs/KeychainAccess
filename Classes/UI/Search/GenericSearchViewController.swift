//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class GenericSearchViewController: FormBuilderViewController, UISearchBarDelegate {

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.autoresizingMask = [.flexibleWidth]
        searchBar.sizeToFit()
        return searchBar
    }()

    private var viewModel: GenericSearchViewModel
    private var searchString: String = ""

    private var searchableSections: [String: [GenericSearchable]] {
        let dict = viewModel.items.reduce([String: [GenericSearchable]]()) { (result, item) -> [String: [GenericSearchable]] in
            var mutableResult = result
            var array = mutableResult[item.section] ?? [GenericSearchable]()
            array.append(item)
            mutableResult[item.section] = array
            return mutableResult
        }

        return dict
    }

    private var prioritisedSections: [PrioritisedSection] {
        var validSections = [PrioritisedSection]()
        var invalidSections = [PrioritisedSection]()

        var mutatedSections = searchableSections

        // Add valid sections to prioritised sections in order
        for (index, item) in viewModel.sectionPriority.enumerated() {
            if let sections = mutatedSections.removeValue(forKey: item) {
                validSections.append(PrioritisedSection(title: item, items: sections))
            }
        }

        // If section is not specified for priority, add to bottom of list in whatever order
        for (key, value) in mutatedSections {
            invalidSections.append(PrioritisedSection(title: key, items: value))
        }

        return validSections + invalidSections
    }

    private var filteredSections: [PrioritisedSection] {
        var filteredSections = [PrioritisedSection]()

        for section in prioritisedSections {
            let validItems = section.items.filter{$0.contains(searchString: searchString)}
            filteredSections.append(PrioritisedSection(title: section.title, items: validItems))
        }

        return filteredSections
    }

    public required init(viewModel: GenericSearchViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchBar)
        updateColour(for: traitCollection)
    }

    override open func construct(builder: FormBuilder) {
        builder.title = viewModel.title
        builder.forceLinearLayout = true

        for section in 0..<numberOfSections() {
            builder += HeaderFormItem(text: title(for: section))

            for row in 0..<numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: name(for: indexPath),
                                            subtitle: description(for: indexPath),
                                            image: image(for: indexPath),
                                            style: .default)
                    .accessory(ItemAccessory.disclosure)
                    .onSelection { [unowned self] cell in
                        self.viewModel.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath)
                }
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            searchBar.frame.origin.y = self.view.safeAreaInsets.top - searchBar.frame.height
            additionalSafeAreaInsets.top = searchBar.frame.height
        } else {
            searchBar.frame.origin.y = topLayoutGuide.length
            legacy_additionalSafeAreaInsets.top = searchBar.frame.size.height
        }
    }

    // MARK: Private

    private func numberOfSections() -> Int {
        let sections = self.filteredSections
        return sections.count
    }

    private func numberOfRows(in section: Int) -> Int {
        let section = filteredSections[section]
        return section.items.count
    }

    private func title(for section: Int) -> String {
        let section = filteredSections[section]
        return section.title
    }

    private func name(for indexPath: IndexPath) -> String {
        let section = filteredSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.title
    }

    private func description(for indexPath: IndexPath) -> String {
        let section = filteredSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.subtitle
    }

    private func image(for indexPath: IndexPath) -> UIImage? {
        let section = filteredSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.image
    }

    private func updateColour(for traitCollection: UITraitCollection) {
        view.backgroundColor = traitCollection.horizontalSizeClass == .compact ? .white : UIColor.white.withAlphaComponent(0.64)
    }

    // MARK: Searchbar delegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        reloadForm()
    }

    // MARK: Traits

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateColour(for: newCollection)
    }
}


/// A generic searchable object
public protocol GenericSearchable {

    /// The main string to display
    var title: String { get }

    /// The subtitle string to display
    var subtitle: String { get }

    /// The section this entity should belong to
    var section: String { get }

    /// The image that should be displayed
    var image: UIImage{ get }

    /// Perform business logic here to check if the entity should show up when filtering
    ///
    /// - Parameter searchString: the search string that is currently beeing filtered with
    /// - Returns: true if should check passes and entity should be displayed
    func contains(searchString: String) -> Bool
}


/// The generic search delegate
public protocol GenericSearchDelegate {

    /// Called when a row of the collection view is tapped
    ///
    /// - Parameters:
    ///   - viewController: the view controller that the tap came form
    ///   - indexPath: the indexPath that was tapped
    func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath)
}

/// A view model for the generic search view controller
public struct GenericSearchViewModel {

    /// The title to be displayed if embedded in nav controller
    ///
    /// default: "Search"
    public var title: String = "Search"

    /// Whether the sections can be collapsed
    ///
    /// default: `true`
    public var collapsableSections: Bool = true

    /// An array of sections sorted by priority
    ///
    /// These should match the sections of your `GenericSeaerchable`s
    ///
    /// If nothing is provided here, the priority of how they are displayed will be determined by
    /// how they are stored in a dictionary
    ///
    /// default: `[]`
    public var sectionPriority: [String] = [String]()

    /// The delegate for the collection view touches
    public var delegate: GenericSearchDelegate?


    /// The array of searchable items
    private(set) var items: [GenericSearchable]


    /// Required initialiser
    ///
    /// - Parameter items: the searchable items
    public init(items: [GenericSearchable]) {
        self.items = items
    }
}

private struct PrioritisedSection {
    var title: String
    var items: [GenericSearchable]

    init(title: String, items: [GenericSearchable]) {
        self.title = title
        self.items = items
    }
}
