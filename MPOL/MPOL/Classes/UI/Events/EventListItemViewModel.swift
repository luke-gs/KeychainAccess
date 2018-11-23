//
//  EventListItemViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

// PSCore demo app implementation of event list item view model
public class EventListItemViewModel: EventListItemViewModelable {
    public var id: String
    public var title: StringSizable?
    public var subtitle: StringSizable?
    public var detail: StringSizable?
    public var image: UIImage?
    public var selectable: Bool
    public var isDraft: Bool

    public init(id: String, title: StringSizable?, subtitle: StringSizable?, detail: StringSizable?, image: UIImage?, selectable: Bool, isDraft: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.image = image
        self.selectable = selectable
        self.isDraft = isDraft
    }
}
