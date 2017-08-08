//
//  EventDetailsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 20/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EventDetailsViewModel: EventDetailsViewModelable {

    public typealias SectionType = EventDetailSection
    public typealias ItemType = EventDetailItem
    
    public var event: Event
    
    public weak var delegate: EntityDetailsViewModelDelegate?
    
    public var sections: [SectionType] = [] {
        didSet {
            delegate?.reloadData()
        }
    }
    
    public required init(event: Event) {
        self.event = event
        prepareSections()
    }
    
    // MARK: - Public methods
    
    public func prepareSections() {
        MPLRequiresConcreteImplementation()
    }
    
    public func numberOfItems(for section: Int) -> Int {
        return sections[ifExists: section]?.items.count ?? 0
    }
    
    public func item(at indexPath: IndexPath) -> ItemType? {
        return sections[ifExists: indexPath.section]?.items[ifExists: indexPath.item]
    }
    
    public func title(for section: Int) -> String? {
        return sections[ifExists: section]?.title
    }
    
    // MARK: - Custom display string
    
    @objc (displayStringForArray:) open func displayString(for array: [String]?) -> String {
        return array?.joined(separator: " ").ifNotEmpty() ?? "-"
    }
    
    @objc (displayStringForDate:) open func displayString(for date: Date?) -> String {
        guard let date = date else { return "-" }
        return DateFormatter.longDateAndTime.string(from: date)
    }
    
    open func displayString(for bool: Bool?) -> String {
        guard let bool = bool else { return "-" }
        return bool ? NSLocalizedString("Yes", bundle: .mpolKit, comment: "Boolean value") : NSLocalizedString("No", bundle: .mpolKit, comment: "Boolean value")
    }
    
    @objc (displayStringForString:) open func displayString(for string: String?) -> String {
        guard let string = string else {
            return "-"
        }
        return string
    }
}


// MARK: - Internal structs

extension EventDetailsViewModel {
    public struct EventDetailSection {
        public var title: String?
        public var items: [EventDetailItem]
    }
    
    public struct EventDetailItem {
        public enum Style {
            case header
            case item
            case valueField
        }
        
        public var style: Style
        public var title: String?
        public var detail: String?
        public var placeholder: String?
        public var image: UIImage?
        public var preferredColumnCount: Int
        public var minimumContentWidth: CGFloat
        
        public init(style: Style = .valueField, title: String?, detail: String?, placeholder: String? = nil, image: UIImage? = nil, preferredColumnCount: Int = 3, minimumContentWidth: CGFloat = 180.0) {
            self.style = style
            self.title = title?.ifNotEmpty()
            self.detail = detail?.ifNotEmpty()
            self.placeholder = placeholder
            self.image = image
            self.preferredColumnCount = preferredColumnCount
            self.minimumContentWidth = minimumContentWidth
        }
    }
}



