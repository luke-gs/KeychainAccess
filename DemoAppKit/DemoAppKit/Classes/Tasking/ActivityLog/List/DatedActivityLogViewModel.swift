//
//  DatedActivityLogViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Activity log view model intended for use with the large dates at the top.
/// This should be subclassed, not used directly.
open class DatedActivityLogViewModel: CADFormCollectionViewModel<ActivityLogItemViewModel> {
    
    public func sortedSectionsByDate(from viewModels: [ActivityLogItemViewModel]) -> [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        
        // Map the keys to an array index, e.g. ['15 Jan, 2018': 0, '14 Jan, 2018': 1], and then keys to view models
        var keyMap = [String: Int]()
        var arr = [[String: [ActivityLogItemViewModel]]]()

        var index = 0
        for item in viewModels {
            let key = dateFormatter.string(from: item.timestamp)
            if keyMap[key] == nil {
                keyMap[key] = index
                arr.insert([key: []], at: index)
                index += 1
            }
            arr[arr.count - 1][key]?.append(item)
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

    open func allowCreate() -> Bool {
        return true
    }

    open func createNewActivityLogViewController() -> UIViewController {
        let viewModel = CreateActivityLogItemViewModel()
        viewModel.startTime = Date().rounded(minutes: 15, rounding: .floor)
        return viewModel.createViewController()
    }
}

