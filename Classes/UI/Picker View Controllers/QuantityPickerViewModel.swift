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
    
    /// Whether to allow the user to enter free text in an 'Other' field
    public var allowsFreeText: Bool = true
    
    /// Maximum number of characters to allow in the free text field. The default is `100`
    public var maxFreeTextCharacters: Int = 100

    public required init(items: [QuantityPicked], subjectMatter: String? = nil) {
        self.items = items
        self.subjectMatter = subjectMatter ?? NSLocalizedString("Items", comment: "Default Quantity Picker Subject Matter")
        if allowsFreeText {
            addFreeTextItemIfRequired()
        }
    }
    
    /// Adds a free text field if no empty ones exist
    public func addFreeTextItemIfRequired() {
        guard allowsFreeText else { return }
        // Check there is no existing empty free text items
        var shouldInsert = true
        for item in items {
            if let item = (item.object as? FreeTextPickable) {
                if (item.value?.count ?? 0) == 0 {
                    shouldInsert = false
                }
            }
        }
        if shouldInsert {
            items.insert(QuantityPicked(object: FreeTextPickable(title: freeTextItemTitle)), at: 0)
        }
    }
    
    public var freeTextItemTitle: String? = NSLocalizedString("Other", comment: "")
}

public class FreeTextPickable: Pickable {
    public var title: String?
    public var subtitle: String?
    
    public var value: String?
    
    init(title: String?, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
