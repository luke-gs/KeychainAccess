//
//  PersonInfoViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class PersonInfoViewModel: EntityDetailFormViewModel {
    
    private var person: Person? {
        return entity as? Person
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        guard let person = person else { return }
        
        // ---------- HEADER ----------
        
        // Values
        let detail =  person.descriptions?.first?.formatted() ?? NSLocalizedString("No description", bundle: .mpolKit, comment: "")
        let count = person.descriptions?.count ?? 0
        let isDetailPlaceholder = count == 0
        let buttonTitle = count <= 1 ? nil : "\(count - 1) MORE DESCRIPTION\(count != 2 ? "S" : "")"
        
        let displayable = PersonSummaryDisplayable(person)
        
        builder += HeaderFormItem(text: header(for: .header), style: .collapsible)
        builder += SummaryDetailFormItem()
            .category(displayable.category)
            .title(displayable.title)
            .subtitle(displayable.detail1)
            .detail(detail)
            .buttonTitle(buttonTitle)
            .borderColor(displayable.borderColor)
            .detailPlaceholder(isDetailPlaceholder)
            .image(displayable.thumbnail(ofSize: .large))
            .onButtonTapped({
                self.didTapAdditionalDetails()
            })
        
        // ---------- LICENCE ----------
        
        let sortedLicences = person.licences?.sorted(using: [SortDescriptor<Licence>(ascending: false) { $0.expiryDate }])
        if let licence = sortedLicences?.first {
            builder += HeaderFormItem(text: header(for: .licence), style: .collapsible)
            builder += ValueFormItem(title: NSLocalizedString("Licence number", bundle: .mpolKit, comment: ""), value: licence.number ?? "-").width(.column(3))
            builder += ValueFormItem(title: NSLocalizedString("State", bundle: .mpolKit, comment: ""), value: licence.state ?? "-").width(.column(3))
            builder += ValueFormItem(title: NSLocalizedString("Country", bundle: .mpolKit, comment: ""), value: licence.country ?? "-").width(.column(3))
            builder += ValueFormItem(title: NSLocalizedString("Status", bundle: .mpolKit, comment: ""), value: licence.status ?? "-").width(.column(3))
            
            var progress: Float = 0
            if let expiryDate = licence.expiryDate {
                progress = Float((Date().timeIntervalSince1970 / expiryDate.timeIntervalSince1970))
            }
            
            builder += ProgressFormItem(title: NSLocalizedString("Valid until", bundle: .mpolKit, comment: ""))
                .value({
                    if let effectiveDate = licence.expiryDate {
                        return DateFormatter.mediumNumericDate.string(from: effectiveDate)
                    } else {
                        return NSLocalizedString("Expiry date unknown", bundle: .mpolKit, comment: "")
                    }
                }())
                .progress(progress)
                .progressTintColor(progress > 1.0 ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1))
                .isProgressHidden(licence.expiryDate == nil)
                .width(.fixed(250))
            
            builder += ValueFormItem(title: NSLocalizedString("Conditions", bundle: .mpolKit, comment: ""), value: licence.conditions?.flatMap({ $0.displayValue() }).joined(separator: "\n")).width(.column(1))
        }
        
        // ---------- ALIASES ----------
        
        if let aliases = person.aliases, !aliases.isEmpty {
            builder += HeaderFormItem(text: header(for: .aliases), style: .collapsible)
            
            for alias in aliases {
                builder += SubtitleFormItem(title: alias.formattedName, subtitle: alias.formattedDOBAgeGender()).width(.column(1))
            }
        }
        
        // ---------- ADDRESSES ----------
        
        if let addresses = person.addresses, !addresses.isEmpty {
            let sort = SortDescriptor<Address>(ascending: false) { $0.reportDate ?? Date.distantPast }
            let sorted = addresses.sorted(using: [sort])
            
            builder += HeaderFormItem(text: header(for: .addresses), style: .collapsible)
            
            for address in sorted {
                builder += ValueFormItem(value: address.formatted(), image: AssetManager.shared.image(forKey: .location))
                    .title({
                        if let date = address.reportDate {
                            return String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), address.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
                        } else {
                            return String(format: NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""), address.type ?? "Unknown")
                        }
                        }())
                    .width(.column(1))
            }
        }
        
        // ---------- CONTACT ----------
        
        if let contacts = person.contacts, !contacts.isEmpty {
            builder += HeaderFormItem(text: header(for: .contact), style: .collapsible)
            
            for contact in contacts {
                builder += ValueFormItem()
                    .title([contact.type?.localizedDescription(), contact.subType].joined(separator: " - "))
                    .value(contact.value?.ifNotEmpty() ?? "-")
                    .image({
                        if let type = contact.type {
                            switch type {
                            case .phone, .mobile:   return AssetManager.shared.image(forKey: .audioCall)
                            case .email:            return AssetManager.shared.image(forKey: .email)
                            }
                        }
                        return nil
                    }())
                    .width(.column(2))
            }
        }
    }
    
    open override var title: String? {
        return NSLocalizedString("Information", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Person Found", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this person", bundle: .mpolKit, comment: "")
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdditionalDetails() {
        let moreDescriptionsVC = PersonDescriptionsViewController()
        moreDescriptionsVC.descriptions = person?.descriptions
        delegate?.presentPushedViewController(moreDescriptionsVC, animated: true)
    }
    
    // MARK: - Internal
    
    private enum Section {
        case header
        case licence
        case aliases
        case addresses
        case contact
    }
    
    private func header(for section: Section) -> String? {
        switch section {
        case .header:
            let lastUpdated: String
            if let date = person?.lastUpdated {
                lastUpdated = DateFormatter.shortDate.string(from: date)
            } else {
                lastUpdated = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return String(format: NSLocalizedString("LAST UPDATED: %@", bundle: .mpolKit, comment: ""), lastUpdated)
        case .licence:
            return NSLocalizedString("LICENCE", bundle: .mpolKit, comment: "")
        case .aliases:
            let count = person?.aliases?.count ?? 0
            switch count {
            case 1:
                return NSLocalizedString("1 ALIAS", bundle: .mpolKit, comment: "")
            default:
                return String(format: NSLocalizedString("%@ ALIASES", bundle: .mpolKit, comment: ""),
                              count > 0 ? "\(count)" : "NO")
            }
        case .addresses:
            let count = person?.addresses?.count ?? 0
            switch count {
            case 1:
                return NSLocalizedString("1 ADDRESS", bundle: .mpolKit, comment: "")
            default:
                return String(format: NSLocalizedString("%@ ADDRESSES", bundle: .mpolKit, comment: ""),
                              count > 0 ? "\(count)" : "NO")
            }
        case .contact:
            return NSLocalizedString("CONTACT DETAILS", bundle: .mpolKit, comment: "")
        }
    }
}

fileprivate extension Alias {
    
    func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            return DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
        } else {
            return NSLocalizedString("DOB Unknown", bundle: .mpolKit, comment: "")
        }
    }
}
