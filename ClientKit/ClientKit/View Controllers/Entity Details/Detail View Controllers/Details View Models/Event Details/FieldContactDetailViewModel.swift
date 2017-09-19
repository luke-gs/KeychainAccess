//
//  FieldContactDetailViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 27/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import Foundation


public class FieldContactDetailViewModel: EventDetailsViewModel {
    
    public override func prepareSections() {
        guard let fieldContact = event as? FieldContact else { return }
        
        let header = EventDetailSection(title: NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(style: .header, title: NSLocalizedString("Field Contact", bundle: .mpolKit, comment: "Detail Title"), detail: NSLocalizedString("Involvement #", bundle: .mpolKit, comment: "title") + fieldContact.id, preferredColumnCount: 1),
            EventDetailItem(title: NSLocalizedString("Occurred on", bundle: .mpolKit, comment: "Detail Title"), detail: displayString(for: fieldContact.contactDate), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)),
            EventDetailItem(title: NSLocalizedString("Status", bundle: .mpolKit, comment: "Detail Title"), detail: fieldContact.status),
            EventDetailItem(title: NSLocalizedString("Contact Member Rank", bundle: .mpolKit, comment: "Detail Title"), detail: fieldContact.contactMember?.rank ?? NSLocalizedString("Unknown", comment: "Unknown Member")),
            EventDetailItem(title: NSLocalizedString("Secondary Contact Member Rank", bundle: .mpolKit, comment: "Detail Title"), detail: fieldContact.secondaryContactMember?.rank ?? NSLocalizedString("Unknown", bundle: .mpolKit, comment: "Unknown Member")),
            EventDetailItem(title: NSLocalizedString("Reporting Station", comment: ""), detail: fieldContact.reportingStation),
            ])
        
        
        let place = EventDetailSection(title: NSLocalizedString("PLACE", bundle: .mpolKit, comment: "Section Title"), items: [
            EventDetailItem(title: NSLocalizedString("Location", bundle: .mpolKit, comment: "Contact location"), detail: fieldContact.contactLocation, image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)),
            EventDetailItem(title: NSLocalizedString("Area Type", bundle: .mpolKit, comment: "Contact location"), detail: fieldContact.areaType),
            EventDetailItem(title: NSLocalizedString("Location Response Zone", bundle: .mpolKit, comment: "Contact location"), detail: fieldContact.locationResponseZone),
            EventDetailItem(title: NSLocalizedString("Neighbourhood Watch Area", bundle: .mpolKit, comment: "Contact location"), detail: fieldContact.neighbourhoodWatchArea),
            EventDetailItem(title: NSLocalizedString("Local Government Area", bundle: .mpolKit, comment: "Contact location"), detail: fieldContact.localGovernmentArea),
            ])
        
        if let descriptions = fieldContact.contactDescriptions?.flatMap({$0.ifNotEmpty()}), descriptions.isEmpty == false {
            let descriptionSection = EventDetailSection(title: NSLocalizedString("CONTACT DESCRIPTIONS", bundle: .mpolKit, comment: "Section Title"),
                                                        items: descriptions.enumerated().map {
                                                            return EventDetailItem(title: String(format: NSLocalizedString("Contact Description %d", comment: ""), $0.offset + 1), detail: $0.element, preferredColumnCount: 1)
                                                        })
            sections = [header, place, descriptionSection]
        } else {
            sections = [header, place]
        }

    }
}
