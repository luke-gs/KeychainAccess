//
//  DatedActivityLogViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Subclass of `ActivityLogViewModel` intended for use with the large dates at the top
public class DatedActivityLogViewModel: ActivityLogViewModel {
//
//    public init(viewModels: [ActivityLogItemViewModel]) {
//        super.init()
//        sections = DatedActivityLogViewModel.sortedSectionsByDate(from: viewModels)
//    }
    
    public func sortedSectionsByDate(from viewModels: [ActivityLogItemViewModel]) -> [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        
        // Map the keys to an array index, e.g. ['15 Jan, 2018': 0, '14 Jan, 2018': 1]
        var keyMap = [String: Int]()
        for (index, item) in viewModels.enumerated() {
            let key = dateFormatter.string(from: item.date)
            if keyMap[key] == nil {
                keyMap[key] = index
            }
        }
        
        // Map the keys to view models
        var arr = [[String: [ActivityLogItemViewModel]]]()
        for item in viewModels {
            let key = dateFormatter.string(from: item.date)
            // Get the index to use for the key
            let keyIndex = keyMap[key]!
            
            // Create the dictionary entry if it doesn't exist
            if arr[ifExists: keyIndex] == nil {
                arr.insert([key: []], at: keyIndex)
            }
            
            // Add the item to the array
            arr[keyIndex][key]?.append(item)
        }
        
        var sections = [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>]()
        for dict in arr {
            for (key, value) in dict {
                sections.append(ActivityLogDateCollectionSectionViewModel(title: key, items: value))
                // TODO: Read, unread
            }
        }
        
        return sections
    }
}

