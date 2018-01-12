//
//  EventDetailsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 20/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class EventDetailsViewModel {
    
    // MARK: - Properties
    
    /// Delegate to update views.
    open weak var delegate: EntityDetailFormViewModelDelegate?
    
    /// The event to request details for.
    private let eventToRequest: Event
    
    /// The fetched event.
    open var event: Event? {
        didSet {
            delegate?.reloadData()
        }
    }
    
    /// The views trait collection.
    open var traitCollection: UITraitCollection?
    
    /// The view controllers title.
    open var title: String? {
        return NSLocalizedString("Event", bundle: .mpolKit, comment: "")
    }
    
    /// Loading manager's no content title.
    open var noContentTitle: String? {
        return NSLocalizedString("No Event Found", bundle: .mpolKit, comment: "")
    }
    
    /// Loading manager's no content subtitle.
    open var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this event", bundle: .mpolKit, comment: "")
    }
    
    /// Loading manager's loading text.
    open var loadingText: String? {
        return NSLocalizedString("Retrieving event", bundle: .mpolKit, comment: "")
    }
    
    // MARK: - Lifecycle
    
    public required init(event: Event) {
        self.eventToRequest = event
    }
    
    /// Fetches the details of the `eventToRequest` and updates loading state.
    open func load() {
        delegate?.updateLoadingState(.loading)
        
        guard let id = event?.id, let source = event?.source else {
            delegate?.updateLoadingState(.noContent)
            return
        }
        
        APIManager.shared.fetchEntityDetails(in: source, with: EntityFetchRequest<Event>(id: id)).then { [weak self] event -> () in
                self?.event = event
                self?.delegate?.updateLoadingState(.loaded)
            }.catch { [weak self] error in
                self?.delegate?.updateLoadingState(.noContent)
        }
    }
    
    /// Builds form with `event` details.
    open func construct(builder: FormBuilder) {
        builder.title = title
        
        guard let event = event else { return }
        
        builder += HeaderFormItem(text: "DETAILS")
        builder += SubtitleFormItem(title: (event.eventType ?? "Event").sizing(withNumberOfLines: 1, font: .systemFont(ofSize: 28.0, weight: .bold)), subtitle: "#" + event.id).width(.column(1))
        builder += ValueFormItem(title: "Status", value: displayString(for: event.status)).width(.column(2))
        builder += ValueFormItem(title: "Occurred On", value: dateTimeDisplayString(for: event.effectiveDate)).width(.column(2))
        builder += ValueFormItem(title: "Created On", value: dateTimeDisplayString(for: event.dateCreated)).width(.column(2))
        builder += ValueFormItem(title: "Created By", value: displayString(for: event.createdBy)).width(.column(2))
        builder += ValueFormItem(title: "Description", value: displayString(for: event.eventDescription)).width(.column(1))
        
        if let addresses = event.addresses, !addresses.isEmpty {
            builder += HeaderFormItem(text: "\(addresses.count) \(addresses.count == 1 ? "ADDRESS" : "ADDRESSES")")
            for address in addresses {
                builder += ValueFormItem(title: title(for: address), value: address.formatted(), image: AssetManager.shared.image(forKey: .location)).width(.column(1))
            }
        }
        
        if let associatedPersons = event.associatedPersons, !associatedPersons.isEmpty {
            builder += HeaderFormItem(text: "\(associatedPersons.count) \(associatedPersons.count == 1 ? "PERSON" : "PEOPLE")")
            for person in associatedPersons {
                let displayable = PersonSummaryDisplayable(person)
                builder += displayable.summaryFormItem(isCompact: traitCollection?.horizontalSizeClass != .compact)
            }
        }
        
        if let associatedVehicles = event.associatedVehicles, !associatedVehicles.isEmpty {
            builder += HeaderFormItem(text: "\(associatedVehicles.count) \(associatedVehicles.count == 1 ? "VEHICLE" : "VEHICLES")")
            for vehicle in associatedVehicles {
                let displayable = VehicleSummaryDisplayable(vehicle)
                builder += displayable.summaryFormItem(isCompact: traitCollection?.horizontalSizeClass != .compact)
            }
        }
    }
    
    /// Gets called when the view controller's trait collection changes.
    open func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        self.traitCollection = traitCollection
        delegate?.reloadData()
    }
    
    // MARK: - Internal
    
    private func title(for address: Address) -> String {
        if let date = address.reportDate {
            return String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), address.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
        } else {
            return String(format: NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""), address.type ?? "Unknown")
        }
    }
    
    // MARK: - Formatting
    
    open func displayString(for array: [String]?) -> String {
        return array?.joined(separator: "\n").ifNotEmpty() ?? "-"
    }
    
    open func dateTimeDisplayString(for date: Date?) -> String {
        guard let date = date else { return "-" }
        return DateFormatter.longDateAndTime.string(from: date)
    }
    
    open func dateOnlyDisplayString(for date: Date?) -> String {
        guard let date = date else { return "-" }
        return DateFormatter.mediumNumericDate.string(from: date)
    }
    
    open func displayString(for bool: Bool?) -> String {
        guard let bool = bool else { return "-" }
        return bool ? NSLocalizedString("Yes", bundle: .mpolKit, comment: "Boolean value") : NSLocalizedString("No", bundle: .mpolKit, comment: "Boolean value")
    }
    
    open func displayString(for string: String?) -> String {
        guard let string = string?.ifNotEmpty() else {
            return "-"
        }
        return string
    }
}
