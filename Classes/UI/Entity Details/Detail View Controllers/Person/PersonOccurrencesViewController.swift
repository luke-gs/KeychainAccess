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
            let eventCount = events?.count ?? 0
            
            hasContent = eventCount > 0
            sidebarItem.count = UInt(eventCount)
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
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let event = events![indexPath.item]
        let cellTexts = appropriateTexts(for: event)
        
        cell.titleLabel.text = cellTexts.titleText
        cell.subtitleLabel.text = cellTexts.subtitleText
        cell.detailLabel.text = cellTexts.detailText
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let detailViewController: UIViewController?
        
        switch events![indexPath.item] {
        case let fieldContact as FieldContact:
            let fieldContactVC = FieldContactDetailViewController()
            fieldContactVC.event = fieldContact
            detailViewController = fieldContactVC
        case let bailOrder as BailOrder:
            let bailOrderVC = BailOrderDetailViewController()
            bailOrderVC.event = bailOrder
            detailViewController = bailOrderVC
        default:
            detailViewController = nil
        }
        
        guard let detailVC = detailViewController,
            let navController = pushableSplitViewController?.navigationController ?? navigationController else { return }
        
        navController.pushViewController(detailVC, animated: true)
    }
    
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
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
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormDetailCell.minimumContentHeight(compatibleWith: traitCollection)
    }


    // MARK: - Private
    // Seems like a common pattern, potential refactor point to have a standard formatter for these?
    
    private func appropriateTexts(for event: AnyObject) -> (titleText: String?, subtitleText: String?, detailText: String?) {
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
            detailText = bailOrder.reportingToStation != nil ? "Report to \(bailOrder.reportingToStation!)" : nil
        case let caution as Caution:
            titleText = "Caution"
            subtitleText = formattedTitle(for: caution.processedDate)
            detailText = caution.cautionDescription
        case let interventionOrder as InterventionOrder:
            titleText = "Intervention Order"
            subtitleText = formattedTitle(for: interventionOrder.servedDate)
            detailText = interventionOrder.type
        case let whereabouts as Whereabouts:
            titleText = "Whereabouts"
            subtitleText = formattedTitle(for: whereabouts.reportDate)
            detailText = whereabouts.notifyMemberDescription != nil ? "Notify \(whereabouts.notifyMemberDescription!)" : nil
        case let warrant as Warrant:
            titleText = "Warrant"
            subtitleText = formattedTitle(for: warrant.issueDate)
            detailText = warrant.warrantDescription
        case let fieldContact as FieldContact:
            titleText = "Field Contact"
            subtitleText = formattedTitle(for: fieldContact.contactDate)
            detailText = fieldContact.contactMember?.stationCode != nil ? "Contact \(fieldContact.contactMember!.stationCode!)" : nil
        case let familyIncident as FamilyIncident:
            titleText = "Family Incident"
            subtitleText = formattedTitle(for: familyIncident.occurrenceDate)
            detailText = familyIncident.incidentDescription
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
