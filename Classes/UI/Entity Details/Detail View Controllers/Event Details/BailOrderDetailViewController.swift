//
//  BailOrderDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 28/5/17.
//
//

import UIKit

open class BailOrderDetailViewController: EventDetailViewController {
    
    /// The bail order event.
    ///
    /// Setting this as any event that is not a bail order sets the event
    /// to `nil`.
    open override var event: Event? {
        get { return super.event }
        set { super.event = newValue as? BailOrder }
    }
    
    private var bailOrder: BailOrder? {
        return event as? BailOrder
    }
    
    open override func updateSections() {
        guard let bailOrder = self.bailOrder else {
            sections = []
            return
        }
        
        let locationImage = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
        let calendarImage = UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)
        
        let header = EventDetailSection(title: NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(style: .header, title: NSLocalizedString("Bail Order", bundle: .mpolKit, comment: "Detail Title"), detail: NSLocalizedString("Involvement #", bundle: .mpolKit, comment: "title") + bailOrder.id, preferredColumnCount: 1)
        ])
        
        // Reporting Requirements
        let reporting = EventDetailSection(title: NSLocalizedString("REPORTING", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Reporting Requirements", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.reportingRequirements), preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Reporting To Station", bundle: .mpolKit, comment: "Detail Title"), detail: bailOrder.reportingToStation, image: locationImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Conditions", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.conditions), preferredColumnCount: 2)
        ])
        
        // Hearing Details
        let hearing = EventDetailSection(title: NSLocalizedString("HEARING", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Hearing Date", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.hearingDate), image: calendarImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Hearing Location", bundle: .mpolKit, comment: "Detail Title"), detail: bailOrder.hearingLocation, image: locationImage, preferredColumnCount: 2)
        ])
        
        // Informant Details
        let informant = EventDetailSection(title: NSLocalizedString("INFORMANT", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Informant Station", bundle: .mpolKit, comment: "Detail Title"), detail: bailOrder.informantStation, image: locationImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Informant Member", bundle: .mpolKit, comment: "Detail Title"), detail: bailOrder.informantMember, image: UIImage(named: "iconEntityPerson", in: .mpolKit, compatibleWith: nil), preferredColumnCount: 2)
        ])
        
        // Posted Details
        let posted = EventDetailSection(title: NSLocalizedString("POSTED", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Posted Date", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.postedDate), image: calendarImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Posted At", bundle: .mpolKit, comment: "Detail Title"), detail: bailOrder.postedAt, image: locationImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Has Owner Undetaking", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.hasOwnerUndertaking), preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("First Report Date", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: bailOrder.firstReportDate), image: calendarImage, preferredColumnCount: 2)
        ])
        
        sections = [header, reporting, hearing, informant, posted]
    }
    
    private func displayString(for array: [String]?) -> String? {
        return array?.joined(separator: " ").ifNotEmpty()
    }
    
    private func displayString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateFormatter.longDateAndTime.string(from: date)
    }
    
    private func displayString(for bool: Bool?) -> String? {
        guard let bool = bool else { return nil }
        return bool ? NSLocalizedString("Yes", bundle: .mpolKit, comment: "Boolean value") : NSLocalizedString("No", bundle: .mpolKit, comment: "Boolean value")
    }
    
}
