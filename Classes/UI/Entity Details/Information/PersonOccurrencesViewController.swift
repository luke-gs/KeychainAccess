//
//  PersonOccurrencesViewController.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Foundation

// TEMP stuff
open class PersonOccurrencesViewController: EntityOccurrencesViewController {

    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            guard let person = self.person else {
                self.events = nil
                return
            }
            
            // HELP: This should be standardised from the middleware
            var events = [[AnyObject]]()
            if let bailOrders = person.bailOrders {
                events.append(bailOrders)
            }
            if let cautions = person.cautions {
                events.append(cautions)
            }
            if let interventionOrders = person.interventionOrders {
                events.append(interventionOrders)
            }
            if let whereabouts = person.whereabouts {
                events.append(whereabouts)
            }
            if let warrants = person.warrants {
                events.append(warrants)
            }
            if let fieldContacts = person.fieldContacts {
                events.append(fieldContacts)
            }
            if let missingPersonReports = person.missingPersonReports {
                events.append(missingPersonReports)
            }
            if let familyIncidents = person.familyIncidents {
                events.append(familyIncidents)
            }
            self.events = events.flatMap{ $0 }
        }
    }
    
    // Help!!
    private var events: [AnyObject]? {
        didSet {
            if let events = events, events.count > 0 {
                self.hasContent = true
            } else {
                self.hasContent = false
            }
            collectionView?.reloadData()
        }
    }
    
    /*
    private var bailOrders: [BailOrder]?
    private var cautions: [Caution]?
    private var fieldContacts: [FieldContact]?
    private var interventionOrders: [InterventionOrder]?
    private var warrants: [Warrant]?
    private var whereabouts: [Whereabouts]?
    private var missingPersons: [MissingPerson]?
    private var familyIncidents: [FamilyIncident]?
    */
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", bundle: .mpolKit, comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Person Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("There are no details for this person", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormDetailCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return events?.isEmpty ?? true ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count =  events?.count ?? 0
        return count
    }
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)

        let event = events![indexPath.item]
        
        let cellTexts = appropriateTextsFor(event)

        cell.titleLabel.text = cellTexts.0
        cell.subtitleLabel.text = cellTexts.1
        cell.detailLabel.text = cellTexts.2
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            // Probably a refactor point as well.
            let eventCount = events?.count ?? 0
            if eventCount > 0 {
                let baseString = eventCount > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, eventCount)
            } else {
                header.text = nil
            }
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }

    // MARK: - Private
    // Seems like a common pattern, potential refactor point to have a standard formatter for these?
    
    private func appropriateTextsFor(_ event: AnyObject) -> (titleText: String?, subtitleText: String?, detailText: String?) {
        let titleText: String?
        let subtitleText: String?
        let detailText: String?
        
        switch event {
        case let mpReport as MissingPersonReport:
            titleText = "Missing Person"
            subtitleText = formattedTitle(for: mpReport.reportedDate)
            detailText = nil
        case let bailOrder as BailOrder:
            titleText = "Bail Order"
            subtitleText = formattedTitle(for: bailOrder.firstReportDate)
            detailText = nil
        case let caution as Caution:
            titleText = "Caution"
            subtitleText = formattedTitle(for: caution.processedDate)
            detailText = nil
        case let interventionOrder as InterventionOrder:
            titleText = "Intervention Order"
            subtitleText = formattedTitle(for: interventionOrder.servedDate)
            detailText = nil
        case let whereabouts as Whereabouts:
            titleText = "Whereabouts"
            subtitleText = formattedTitle(for: whereabouts.reportDate)
            detailText = nil
        case let warrant as Warrant:
            titleText = "Warrant"
            subtitleText = formattedTitle(for: warrant.issueDate)
            detailText = nil
        case let fieldContact as FieldContact:
            titleText = "Field Contact"
            subtitleText = formattedTitle(for: fieldContact.contactDate)
            detailText = nil
        case let familyIncident as FamilyIncident:
            titleText = "Family Incident"
            subtitleText = formattedTitle(for: familyIncident.occurrenceDate)
            detailText = nil
        default:
            titleText = "Unknown"
            subtitleText = formattedTitle(for: nil)
            detailText = nil
            break
        }
        
        return (titleText: titleText, subtitleText: subtitleText, detailText: detailText)
    }
    
    private func formattedTitle(for date: Date?) -> String {
        let text: String
        if let date = date {
            text = DateFormatter.mediumNumericDate.string(from: date)
        } else {
            text = "unknown"
        }
        return "Occurred on \(text)"
    }
}

private enum SectionType {
    case bailOrder
    case caution
    case fieldContact
    case interventionOrder
    case warrant
    case whereabouts
    case missingPerson
    case familyIncident
}
