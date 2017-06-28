//
//  InterventionOrderDetailViewController.swift
//  Pods
//
//  Created by Gridstone on 29/5/17.
//
//

import UIKit

class InterventionOrderDetailViewController: EventDetailViewController {
    
    /// The intervention order event.
    ///
    /// Setting this as any event that is not a intervention order sets the event
    /// to `nil`.
    open override var event: Event? {
        get { return super.event }
        set { super.event = newValue as? InterventionOrder }
    }
    
    private var interventionOrder: InterventionOrder? {
        return event as? InterventionOrder
    }
    
    open override func updateSections() {
        guard let interventionOrder = self.interventionOrder else {
            sections = []
            return
        }
        
        let locationImage = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
        let calendarImage = UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)
        
        let header = EventDetailSection(title: NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(style: .header, title: NSLocalizedString("Intervention Order", bundle: .mpolKit, comment: "Detail Title"), detail: NSLocalizedString("Involvement #", bundle: .mpolKit, comment: "title") + interventionOrder.id, preferredColumnCount: 1)
            ])
        
        // Order Details
        let order = EventDetailSection(title: NSLocalizedString("ORDER DETAILS", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Type", bundle: .mpolKit, comment: "Detail Title"), detail: interventionOrder.type, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Served Date", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: interventionOrder.servedDate), image: calendarImage, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Address", bundle: .mpolKit, comment: "Detail Title"), detail: interventionOrder.address, image: locationImage, preferredColumnCount: 1)
            ])
        
        let respondent = EventDetailSection(title: NSLocalizedString("RESPONDENT DETAILS", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Respondent Name", bundle: .mpolKit, comment: "Detail Title"), detail: interventionOrder.respondentName, preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Respondent Date of Birth", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: interventionOrder.respondentDateOfBirth), image: calendarImage, preferredColumnCount: 2)
            ])
        
        let status = EventDetailSection(title: NSLocalizedString("INTERVENTION DETAILS", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Status", bundle: .mpolKit, comment: "Detail Title"), detail: interventionOrder.status, preferredColumnCount: 1),
            EventDetailItem(title: NSLocalizedString("Complaints", bundle: .mpolKit, comment: "Detail Title"), detail: "-", preferredColumnCount: 2),
            EventDetailItem(title: NSLocalizedString("Conditions", bundle: .mpolKit, comment: "Detail Title"), detail: "-", preferredColumnCount: 2)
            ])
        
        sections = [header, order, respondent, status]
    }
    
    // TODO: Bring logic to superclass
    private func displayString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateFormatter.longDateAndTime.string(from: date)
    }
}
