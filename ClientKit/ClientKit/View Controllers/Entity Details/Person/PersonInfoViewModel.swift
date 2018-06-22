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

        builder += SummaryDetailFormItem()
            .separatorColor(.clear)
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
                builder += LargeTextHeaderFormItem(text: formatter.headerText)
                    .separatorColor(.clear)

                for formItem in formatter.classesFormItems {
                    builder += formItem
                }
            }

        } else {
            if let licence = sortedLicences.first {
                builder += LargeTextHeaderFormItem(text: header(for: .details))
                    .separatorColor(.clear)
                let title = StringSizing(string: NSLocalizedString("Identification Number", comment: ""), font: UIFont.preferredFont(forTextStyle: .subheadline))
                let value = StringSizing(string: licence.number ?? "-", font: UIFont.preferredFont(forTextStyle: .subheadline))
                builder += ValueFormItem(title: title, value: value)
                    .width(.column(1))
            }
        }

        
        // ---------- ALIASES ----------
        
        if let aliases = person.aliases, !aliases.isEmpty {
            builder += LargeTextHeaderFormItem(text: header(for: .aliases))
                .separatorColor(.clear)
            
            for alias in aliases {
                SubtitleFormItem(title: alias.formattedName, subtitle: alias.formattedDOBAgeGender()).width(.column(1))

                let value = StringSizing(string: alias.formattedName ?? "", font: UIFont.preferredFont(forTextStyle: .subheadline))
                let title: StringSizing = {
                    let title: String
                    if let date = alias.dateCreated {
                        title = String(format: NSLocalizedString("Recorded on %@", bundle: .mpolKit, comment: ""), DateFormatter.preferredDateStyle.string(from: date))
                    } else {
                        title = NSLocalizedString("Recorded date unknown", bundle: .mpolKit, comment: "")
                    }
                    return StringSizing(string: title, font: UIFont.preferredFont(forTextStyle: .subheadline))
                }()

                builder += ValueFormItem(value: value, image: nil)
                    .title(title)
                    .width(.column(1))
            }
        }
        
        // ---------- ADDRESSES ----------
        
        if let addresses = person.addresses, !addresses.isEmpty {
            let sort = SortDescriptor<Address>(ascending: false) { $0.reportDate ?? Date.distantPast }
            let sorted = addresses.sorted(using: [sort])
            
            builder += LargeTextHeaderFormItem(text: header(for: .addresses))
                .separatorColor(.clear)
            
            for address in sorted {

                let title = StringSizing(string: address.type ?? "Unknown", font: UIFont.preferredFont(forTextStyle: .subheadline))
                let subtitle = StringSizing(string: address.formatted() ?? "", font: UIFont.preferredFont(forTextStyle: .subheadline))

                let detail: StringSizing = {
                    let detail: String
                    if let date = address.reportDate {
                        detail = String(format: NSLocalizedString("Recorded on %@", bundle: .mpolKit, comment: ""), DateFormatter.preferredDateStyle.string(from: date))
                    } else {
                        detail = NSLocalizedString("Recorded date unknown", bundle: .mpolKit, comment: "")
                    }
                    return StringSizing(string: detail, font: UIFont.preferredFont(forTextStyle: .footnote))
                }()
                builder += DetailLinkFormItem()
                    .title(title)
                    .subtitle(subtitle)
                    .detail(detail)
                    .width(.column(1))
                    .onSelection({ cell in
                        // TODO: add actual functionality when tapping address when it is decided
                        print(address.fullAddress)
                    })
            }
        }
        
        // ---------- CONTACT ----------
        
        if let contacts = person.contacts, !contacts.isEmpty {
            builder += LargeTextHeaderFormItem(text: header(for: .contact))
                .separatorColor(.clear)
            
            for contact in contacts {
                let title = StringSizing(string: [contact.type?.localizedDescription(), contact.subType].joined(separator: " - "), font: UIFont.preferredFont(forTextStyle: .subheadline))
                let subtitle = StringSizing(string: contact.value?.ifNotEmpty() ?? "-", font: UIFont.preferredFont(forTextStyle: .subheadline))

                let detail: StringSizing = {
                    let detail: String
                    if let date = contact.dateCreated {
                        detail = String(format: NSLocalizedString("Recorded on %@", bundle: .mpolKit, comment: ""), DateFormatter.preferredDateStyle.string(from: Date()))
                    } else {
                        detail = NSLocalizedString("Recorded date unknown", bundle: .mpolKit, comment: "")
                    }
                    return StringSizing(string: detail, font: UIFont.preferredFont(forTextStyle: .footnote))
                }()

                builder += DetailLinkFormItem()
                    .title(title)
                    .subtitle(subtitle)
                    .detail(detail)
                    .width(.column(2))
                    .onSelection({
                        if contact.type == .email {
                            return { cell in
                                // TODO: add actual functionality when tapping email when it is decided
                                print(contact.value)
                            }
                        }
                        return nil
                    }())
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
        return AssetManager.shared.image(forKey: .infoFilled)
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
        case details
        case licence
        case aliases
        case addresses
        case contact
    }
    
    private func header(for section: Section) -> String? {
        switch section {
        case .header:
            return nil
        case .details:
            return NSLocalizedString("Details", comment: "")
        case .licence:
            return nil
        case .aliases:
            return NSLocalizedString("Aliases", bundle: .mpolKit, comment: "")
        case .addresses:
            return NSLocalizedString("Addresses", bundle: .mpolKit, comment: "")
        case .contact:
            return NSLocalizedString("Contact Details", bundle: .mpolKit, comment: "")
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
