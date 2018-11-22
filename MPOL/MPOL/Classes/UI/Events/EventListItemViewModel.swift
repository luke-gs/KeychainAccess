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
    public var title: String?
    public var subtitle: String?
    public var detail: String?
    public var image: UIImage?
    public var isDraft: Bool

    public init(id: String, title: String?, subtitle: String?, detail: String?, image: UIImage?, isDraft: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.image = image
        self.isDraft = isDraft
    }
}
