//
//  BailOrderDetailViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 27/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import Foundation

public class BailOrderDetailViewModel: EventDetailsViewModel {
    
    public override func prepareSections() {
        guard let bailOrder = event as? BailOrder else { return }
        
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
}
