//
//  TaskItemViewModelTests.swift
//  MPOLKitTests
//
//  Created by Kara Valentine on 27/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class TaskItemViewModelTests: XCTestCase {

    // blank implementation of TaskDetailsViewModel for testing
    class TaskDetailsViewModelTestImplementation: TaskDetailsViewModel {
        func createViewController() -> UIViewController {
            return UIViewController()
        }
    }

    func testInitialiser() {
        // Arrange
        let iconImage: UIImage? = UIImage()
        let iconTintColor: UIColor? = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        let color: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let statusText: String? = "Active"
        let itemName: String? = "Test Item"
        let lastUpdated: String? = "12 June 2009"
        let viewModels: [TaskDetailsViewModel] = [TaskDetailsViewModelTestImplementation()]
        
        // Act
        let testModel = TaskItemViewModel(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, lastUpdated: lastUpdated, viewModels: viewModels)
        
        // Assert
        XCTAssert(
            iconImage == testModel.iconImage &&
            iconTintColor == testModel.iconTintColor &&
            color == testModel.color &&
            statusText == testModel.statusText &&
            itemName == testModel.itemName &&
            lastUpdated == testModel.lastUpdated &&
            viewModels.count == testModel.viewModels.count // can't do an equality check, this will do
        )
    }

    func testDetailViewControllers() {
        // Arrange
        let viewModels: [TaskDetailsViewModel] = [TaskDetailsViewModelTestImplementation(), TaskDetailsViewModelTestImplementation()]
        let testModel = TaskItemViewModel(iconImage: nil, iconTintColor: nil, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), statusText: nil, itemName: nil, lastUpdated: nil, viewModels: viewModels)

        // Act
        let detailViewControllers = testModel.detailViewControllers()

        // Assert
        XCTAssertEqual(detailViewControllers.count, viewModels.count)
    }
}
