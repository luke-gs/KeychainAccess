//
//  QuantityPickerViewModel.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class QuantityPickerViewModel {

    /// Array of items that are used as the data source for the picker.
    public var items: [QuantityPicked] = []

    /// Used in Navigation Bar title as "Add <SubjectMatter>" and in the Search header title as "X <SubjectMatter>" selected.
    public var subjectMatter: String

    public required init(items: [QuantityPicked], subjectMatter: String? = nil) {
        self.items = items
        self.subjectMatter = subjectMatter ?? NSLocalizedString("Items", comment: "Default Quantity Picker Subject Matter")
    }
}
