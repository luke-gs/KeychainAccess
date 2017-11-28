//
//  TasksListViewModelTests.swift
//  MPOLKitTests
//
//  Created by Kara Valentine on 27/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

private class TasksListViewModelTests: XCTestCase {

    var testModel: TasksListViewModel?

    override func setUp() {
        // Arrange
        testModel = TasksListViewModel()
    }

    func testCreateViewControllerReturnsValue() {
        // Act
        let viewController: FormCollectionViewController = testModel!.createViewController()

        // Assert
        XCTAssertNotNil(viewController)
    }

    func testNavTitleReturnsValue() {
        // Act
        let navTitle: String? = testModel!.navTitle()

        // Assert
        XCTAssertNotNil(navTitle)
    }

    func testNoContentTitleReturnsValue() {
        // Act
        let noContentTitle: String? = testModel!.noContentTitle()

        // Assert
        XCTAssertNotNil(noContentTitle)
    }

    func testNoContentSubtitleReturnsNil() {
        // Act
        let noContentSubtitle: String? = testModel!.noContentSubtitle()

        // Assert
        XCTAssertNil(noContentSubtitle)
    }

    func testShowUpdatesIndicatorIsFalseWhenNoUpdatesRequired() {
        // Arrange
        let tasksListItemViewModel = TasksListItemViewModel(title: "Title", subtitle: "Subtitle", caption: "Caption", boxColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), boxFilled: false, hasUpdates: false)
        testModel!.sections = [CADFormCollectionSectionViewModel<TasksListItemViewModel>(title: "Test", items: [tasksListItemViewModel])]

        // Act
        let showUpdatesIndicator = testModel!.showsUpdatesIndicator(at: 0)

        // Assert
        XCTAssertFalse(showUpdatesIndicator)
    }

    func testShowUpdatesIndicatorIsTrueWhenUpdatesRequired() {
        // Arrange
        let tasksListItemViewModel = TasksListItemViewModel(title: "Title", subtitle: "Subtitle", caption: "Caption", boxColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), boxFilled: false, hasUpdates: true)
        testModel!.sections = [CADFormCollectionSectionViewModel<TasksListItemViewModel>(title: "Test", items: [tasksListItemViewModel])]

        // Act
        let showUpdatesIndicator = testModel!.showsUpdatesIndicator(at: 0)

        // Assert
        XCTAssert(showUpdatesIndicator)
    }
}
