//
//  GenericSearchViewModelTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class GenericSearchViewModelTests: XCTestCase {

    private lazy var items: [GenericSearchable] = {
        let items: [GenericSearchable] = Array<GenericSearchable>(repeating: Test(), count: 10) + Array<GenericSearchable>(repeating: Test3(), count: 2)
        return items
    }()

    private lazy var viewModel: GenericSearchDefaultViewModel = {
        let viewModel = GenericSearchDefaultViewModel(items: items)
        return viewModel
    }()

    func testDefaultViewModel() {
        XCTAssertTrue(viewModel.collapsableSections)
        XCTAssertTrue(viewModel.hasSections)
        XCTAssertTrue(viewModel.hidesSections)
    }

    func testNumberOfValidSections() {
        let numberOfSections = Set(items.flatMap{$0.section}).count
        XCTAssertEqual(viewModel.numberOfSections(), numberOfSections)
    }

    func testNumberOfSectionsPlusOtherSection() {
        let items: [GenericSearchable] = Array<GenericSearchable>(repeating: Test(), count: 10) + Array<GenericSearchable>(repeating: Test2(), count: 2)
        let viewModel = GenericSearchDefaultViewModel(items: items)

        let numberOfSections = Set(items.flatMap{$0.section}).count
        XCTAssertNotEqual(viewModel.numberOfSections(), numberOfSections)
        XCTAssertEqual(viewModel.numberOfSections(), numberOfSections + 1)
    }

    func testNumberOfRowsInSection() {
        let numberOfRows = items.filter{$0.title == Test3().title}.count
        XCTAssertEqual(viewModel.numberOfRows(in: 0), numberOfRows)
    }

    func testTitleForSection() {
        let sectionTitle = items.map{$0.section}.filter{$0 == Test3().section}.first
        if let sectionTitle = sectionTitle {
            XCTAssertEqual(viewModel.title(for: 0), sectionTitle)
        }
    }

    func testTitleForRow() {
        let rows = items.filter{$0.title == Test3().title}
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(viewModel.title(for: indexPath), rows.first?.title)
    }

    func testDescriptionForRow() {
        let rows = items.filter{$0.subtitle == Test3().subtitle}
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(viewModel.description(for: indexPath), rows.first?.subtitle)
    }

    func testImageForRow() {
        let rows = items.filter{$0.title == Test().title}
        let indexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(viewModel.image(for: indexPath), rows.first?.image)
    }

    func testSearchableForRow() {
        let rows = items.filter{$0.title == Test().title}
        let indexPath = IndexPath(row: 0, section: 1)
        if let searchable = rows.first {
            XCTAssertEqual(viewModel.searchable(for: indexPath).title, searchable.title)
        }
    }

    func testSearchableForRowWithPriortiy() {
        viewModel.sectionPriority = ["On Duty", "Duress"]

        let rows = items.filter{$0.title == Test().title}
        let indexPath = IndexPath(row: 0, section: 0)
        if let searchable = rows.first {
            XCTAssertEqual(viewModel.searchable(for: indexPath).title, searchable.title)
        }
    }

    func testSearchableForRowWithPriortiyAndSearchText() {
        viewModel.sectionPriority = ["On Duty", "Duress"]
        viewModel.searchTextChanged(to: "James")

        let rows = items.filter{$0.title == Test().title}
        let indexPath = IndexPath(row: 0, section: 0)
        if let searchable = rows.first {
            XCTAssertEqual(viewModel.searchable(for: indexPath).title, searchable.title)
        }
    }
}


struct Test: GenericSearchable {
    var title: String = "James"
    var subtitle: String? = "Neverdie"
    var section: String? = "On Duty"
    var image: UIImage? = UIImage()

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test2: GenericSearchable {
    var title: String = "Herli"
    var subtitle: String? //= "Chad"
    var section: String? //= "On Air"
    var image: UIImage?  //= UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test3: GenericSearchable {
    var title: String = "Luke"
    var subtitle: String? = "Jimmy Boy"
    var section: String? = "Duress"
    var image: UIImage? // = UIImage(named: "SidebarAlertFilled")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString) || (subtitle?.contains(searchString) ?? false)
    }
}
