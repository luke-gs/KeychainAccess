//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

final public class GenericSearchViewController: FormBuilderViewController, UISearchBarDelegate {

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


    /* Internal section prioritisation
     *
     * If you require to change this logic to suit your business cases
     * Then this logic should no longer sit in the view controller
     * And you should consider rewriting how this class and the viewmodel interact
     */

    // ***************** START ********************

    private var searchableSections: [String: [GenericSearchable]] {
        let dict = viewModel.items.reduce([String: [GenericSearchable]]()) { (result, item) -> [String: [GenericSearchable]] in
            let section = item.section ?? "Other"
            var mutableResult = result
            var array = mutableResult[section] ?? [GenericSearchable]()
            array.append(item)
            mutableResult[section] = array
            return mutableResult
        }

        return dict
    }

    private var prioritisedSections: [PrioritisedSection] {
        let descriptor = SortDescriptor<PrioritisedSection>(ascending: true) { $0.title }

        var validSections = [PrioritisedSection]()
        var invalidSections = [PrioritisedSection]()
        var mutatedSections = searchableSections

        // Add valid sections to prioritised sections in order
        for item in viewModel.sectionPriority {
            if let sections = mutatedSections.removeValue(forKey: item) {
                validSections.append(PrioritisedSection(title: item, items: sections))
            }
        }

        // If section is not specified for priority, add to bottom of list in whatever order
        for (key, value) in mutatedSections {
            invalidSections.append(PrioritisedSection(title: key, items: value))
        }

        // Sort alphabetically if there are is no section priority
        invalidSections = viewModel.sectionPriority.count > 0 ? invalidSections : invalidSections.sorted(using: [descriptor])

        return (validSections + invalidSections)
    }

    private var filteredSections: [PrioritisedSection] {
        var filteredSections = [PrioritisedSection]()

        for section in prioritisedSections {
            let validItems = section.items.filter{$0.matches(searchString: searchString)}
            var section = PrioritisedSection(title: section.title, items: validItems)
            section.isHidden = viewModel.hidesSections && validItems.count == 0
            filteredSections.append(section)
        }

        return filteredSections
    }

    private var validSections: [PrioritisedSection] {
        return searchString != "" ? filteredSections : prioritisedSections
    }

    // ***************** END ********************

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
            if viewModel.hasSections == true && hidden(for: section) == false {
                builder += HeaderFormItem(text: title(for: section))
            }
            for row in 0..<numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: name(for: indexPath),
                                            subtitle: description(for: indexPath),
                                            image: image(for: indexPath),
                                            style: .default)
                    .accessory(ItemAccessory.disclosure)
                    .onSelection { [unowned self] cell in
                        let searchable = self.validSections[section].items[row]
                        self.viewModel.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath, withSearchable: searchable)
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
        let sections = validSections
        return sections.count
    }

    private func numberOfRows(in section: Int) -> Int {
        let section = validSections[section]
        return section.items.count
    }

    private func title(for section: Int) -> String {
        let section = validSections[section]
        return section.title
    }

    private func hidden(for section: Int) -> Bool {
        return validSections[section].isHidden
    }

    private func name(for indexPath: IndexPath) -> String {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.title
    }

    private func description(for indexPath: IndexPath) -> String? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.subtitle
    }

    private func image(for indexPath: IndexPath) -> UIImage? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.image
    }

    private func updateColour(for traitCollection: UITraitCollection) {
        let shouldBeWhite = traitCollection.horizontalSizeClass == .compact || !self.isBeingPresented
        view.backgroundColor = shouldBeWhite ? .white : UIColor.white.withAlphaComponent(0.64)
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
    var subtitle: String? { get }

    /// The section this entity should belong to
    ///
    /// defaults to: `"Other"` if not provided
    var section: String? { get }

    /// The image that should be displayed
    var image: UIImage? { get }

    /// Perform business logic here to check if the entity should show up when filtering
    ///
    /// - Parameter searchString: the search string that is currently being filtered with
    /// - Returns: true if should check passes and entity should be displayed
    func matches(searchString: String) -> Bool
}


/// The generic search delegate
public protocol GenericSearchDelegate {

    /// Called when a row of the collection view is tapped
    ///
    /// - Parameters:
    ///   - viewController: the view controller that the tap came form
    ///   - indexPath: the indexPath that was tapped
    ///   - withSearchable: teh searchable object for that indexPath
    func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath, withSearchable: GenericSearchable)
}

/// A view model for the generic search view controller
public class GenericSearchViewModel {

    /// The title to be displayed if embedded in nav controller
    ///
    /// default: "Search"
    public var title: String = "Search"

    /// Whether the sections can be collapsed
    ///
    /// default: `true`
    public var collapsableSections: Bool = true

    /// Whether the list should be broken down by sections defined in the the `searchables`
    ///
    /// default: `true`
    public var hasSections: Bool = true

    /// Whether the list should hide sections when no results are found
    ///
    /// default: `false`
    public var hidesSections: Bool = false

    /// An array of sections sorted by priority
    ///
    /// These should match the sections of your `GenericSearchable`s
    ///
    /// If nothing is provided here the sections will be sorted by alphabetical order
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
    var isHidden: Bool = false

    init(title: String, items: [GenericSearchable]) {
        self.title = title
        self.items = items
    }
}
