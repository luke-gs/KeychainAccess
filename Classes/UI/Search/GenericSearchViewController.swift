//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol GenericSearchable {
    var title: String { get }
    var subtitle: String { get }
    var section: String { get }
    var image: UIImage{ get }
    func contains(searchString: String) -> Bool
}

public protocol GenericSearchDelegate {
    func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath)
}

public struct GenericSearchViewModel {
    public var title: String = "Search"
    public var expandableSections: Bool = true
    public var delegate: GenericSearchDelegate?
    public var sectionPriority: [String] = [String]()

    internal var items: [GenericSearchable]

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

open class GenericSearchViewController: FormBuilderViewController, UISearchBarDelegate {

    private lazy var testHeader: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 80))
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        return searchBar
    }()

    private var viewModel: GenericSearchViewModel
    private var searchString: String = ""
    private var isSearching: Bool {
        return searchString != nil && searchString != ""
    }

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
        self.view.addSubview(testHeader)
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
            testHeader.frame.origin.y = self.view.safeAreaInsets.top - testHeader.frame.height
            testHeader.frame.size.width = self.view.frame.size.width
            additionalSafeAreaInsets.top = testHeader.frame.height
        } else {
            // Fallback on earlier versions
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

