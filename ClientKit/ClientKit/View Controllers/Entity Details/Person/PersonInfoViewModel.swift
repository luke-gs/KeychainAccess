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

    // TODO: Probably think of how this should be used a bit further
    public init(showingLicenceDetails: Bool = true) {
        self.showingLicenceDetails = showingLicenceDetails
    }

    public let showingLicenceDetails: Bool

    private var person: Person? {
        return entity as? Person
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        guard let person = person else { return }
        
        // ---------- HEADER ----------
        
        // Values
        let detail = person.descriptions?.first?.formatted() ?? NSLocalizedString("No description", bundle: .mpolKit, comment: "")
        let count = person.descriptions?.count ?? 0
        let isDetailPlaceholder = count == 0
        let buttonTitle = count <= 1 ? nil : "\(count - 1) MORE DESCRIPTION\(count != 2 ? "S" : "")"
        
        let displayable = PersonDetailsDisplayable(person)
        
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
            .imageTintColor(displayable.iconColor)
            .onButtonTapped {
                self.didTapAdditionalDetails()
        }
        
        // ---------- LICENCE ----------
        
        let sortedLicences = person.licences?.sorted(using: [SortDescriptor<Licence>(ascending: false) { $0.expiryDate }]) ?? []


        if showingLicenceDetails {

            for licence in sortedLicences {

                let formatter = LicenceFormatter(licence: licence)
                builder += HeaderFormItem(text: formatter.headerText, style: .collapsible)

                for formItem in formatter.classesFormItems {
                    builder += formItem
                }
            }

        } else {
            if let licence = sortedLicences.first {
                builder += HeaderFormItem(text: header(for: .details), style: .collapsible)
                builder += ValueFormItem(title: NSLocalizedString("Identification Number", comment: ""), value: licence.number ?? "-").width(.column(1))
            }
        }

        
        // ---------- ALIASES ----------
        
        if let aliases = person.aliases, !aliases.isEmpty {
            builder += HeaderFormItem(text: header(for: .aliases), style: .collapsible)
            
            for alias in aliases {
                SubtitleFormItem(title: alias.formattedName, subtitle: alias.formattedDOBAgeGender()).width(.column(1))
                builder += ValueFormItem(value: alias.formattedName, image: nil)
                    .title({
                        if let date = alias.dateCreated {
                            return String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), alias.type ?? "Unknown", DateFormatter.preferredDateStyle.string(from: date))
                        } else {
                            return String(format: NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""), alias.type ?? "Unknown")
                        }
                    }()).width(.column(1))
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
                            return String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), address.type ?? "Unknown", DateFormatter.preferredDateStyle.string(from: date))
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
                            case .phone, .mobile:
                                return AssetManager.shared.image(forKey: .audioCall)
                            case .email:
                                return AssetManager.shared.image(forKey: .email)
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
        guard let descriptions = person?.descriptions else { return }
        let moreDescriptionsVC = PersonDescriptionViewController(descriptions: descriptions)
        delegate?.presentPushedViewController(moreDescriptionsVC, animated: true)
    }
    
    // MARK: - Internal

    // TODO: - Probably refactor this thing.
    // Enum probably is not the best place to do "text" presentation.
    private enum Section {
        case header
        case licence
        case aliases
        case addresses
        case contact
        case details
    }
    
    private func header(for section: Section) -> String? {
        switch section {
        case .header:
            let lastUpdated: String
            if let date = person?.lastUpdated {
                lastUpdated = DateFormatter.preferredDateStyle.string(from: date)
            } else {
                lastUpdated = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return String(format: NSLocalizedString("LAST UPDATED: %@", bundle: .mpolKit, comment: ""), lastUpdated)
        case .licence:
            return ""
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
        case .details:
            return NSLocalizedString("DETAILS", comment: "")
        }
    }
}

fileprivate extension Alias {
    
    func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            return DateFormatter.preferredDateStyle.string(from: dob) + " (\(yearComponent.year!)"
        } else {
            return NSLocalizedString("DOB Unknown", bundle: .mpolKit, comment: "")
        }
    }
}

struct LicenceFormatter {
    let licence: Licence
    let classesFormItems: [DetailFormItem]

    init(licence: Licence) {
        self.licence = licence
        if let licenceClasses = licence.licenceClasses {
            classesFormItems = licenceClasses.map { LicenceClassFormatter(licenceClass: $0, isSuspended: licence.isSuspended).formItem() }
        } else {
            classesFormItems = []
        }

    }

    var headerText: String {
        if let number = licence.number {
            return String(format: NSLocalizedString("LICENCE #%@", comment: ""), number)
        } else {
            return NSLocalizedString("LICENCE", comment: "")
        }
    }
}

struct LicenceClassFormatter: DetailDisplayable, FormItemable {

    let calendar: Calendar = Calendar.current

    let hasExpired: Bool
    let licenceClass: Licence.LicenceClass

    let validLicence: Bool

    private let _subtitle: StringSizing?

    init(licenceClass: Licence.LicenceClass, isSuspended: Bool) {
        self.licenceClass = licenceClass
        hasExpired = false

        var valid = true

        if isSuspended  {
            valid = false
            _subtitle = NSAttributedString(string: NSLocalizedString("Suspended", comment: ""), attributes: [ .foregroundColor: UIColor.orangeRed ]).sizing(withNumberOfLines: 0)
        } else {
            if let expiryDate = licenceClass.expiryDate {
                let dayComponent = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate)
                if let day = dayComponent.day {
                    if day > 0 {
                        let text = String(format: NSLocalizedString("Valid Until %@", comment: ""), DateFormatter.preferredDateStyle.string(from: expiryDate))
                        _subtitle = text.sizing(withNumberOfLines: 0)
                    } else {
                        let text = String(format: NSLocalizedString("Expired Since %1$@ (%2$d day(s))", comment: ""), DateFormatter.preferredDateStyle.string(from: expiryDate), abs(day))
                        _subtitle = NSAttributedString(string: text, attributes: [ .foregroundColor: UIColor.orangeRed ]).sizing(withNumberOfLines: 0)
                        valid = false
                    }
                } else {
                    _subtitle = nil
                }

            } else {
                _subtitle = nil
            }
        }
        validLicence = valid
    }

    var image: UIImage? {
        if validLicence {
            return UIImage.statusDot(withColor: .midGreen)
        } else {
            return UIImage.statusDot(withColor: .brightBlue)
        }
    }

    var title: StringSizing? {
        let text = licenceClass.code ?? NSLocalizedString("Unknown", comment: "")
        return text.sizing(withNumberOfLines: 0)
    }

    var subtitle: StringSizing? {
        return _subtitle
    }

    var detail: StringSizing? {
        let conditions = licenceClass.conditions?.compactMap { $0.condition } ?? []
        let conditionText = conditions.joined(separator: ", ")
        return String(format: NSLocalizedString("Conditions: %@", comment: ""), conditionText).sizing(withNumberOfLines: 0)
    }
}
