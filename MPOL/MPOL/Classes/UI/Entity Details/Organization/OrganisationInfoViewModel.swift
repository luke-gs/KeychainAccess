//
//  OrganisationInfoViewModel.swift
//  ClientKit
//
//  Created by Megan Efron on 11/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

open class OrganisationInfoViewModel: EntityDetailFormViewModel, EntityLocationMapDisplayable {
    
    private var organisation: Organisation? {
        return entity as? Organisation
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        
        guard let organisation = organisation else {
            return
        }
        
        builder.title = title
        
        builder += LargeTextHeaderFormItem(text: NSLocalizedString("DETAILS", comment: ""), separatorColor: .clear)
        
        builder += locationBlock(for: organisation)
        
        builder += detailsBlock(for: organisation)
        
        builder += aliasBlock(for: organisation)
    }
    
    private func locationBlock(for organisation: Organisation) -> [FormItem] {
        return [
            ValueFormItem(title: NSLocalizedString("Address", comment: ""), value: organisation.locations?.first?.fullAddress)
            .width(.column(1)).highlightStyle(.fade).separatorColor(.clear),
            ValueFormItem(title: NSLocalizedString("Latitude, Longitude", comment: ""), value: latLongString())
            .width(.column(1)).separatorColor(.clear)
        ]
    }
    
    private func detailsBlock(for organisation: Organisation) -> [FormItem] {
        var items = [FormItem]()
        items.append(ValueFormItem(title: NSLocalizedString("Organisation Type", comment: ""), value: organisation.type).width(.column(3)))
        
        if let acn = organisation.acn {
             items.append(ValueFormItem(title: NSLocalizedString("ABN/ACN", comment: ""), value: acn).width(.column(3)))
        } else {
            items.append(ValueFormItem(title: NSLocalizedString("ABN/ACN", comment: ""), value: organisation.abn).width(.column(3)))
        }
        
        if let effectiveDate = organisation.effectiveDate {
            let dateString = DateFormatter.preferredDateStyle.string(from: effectiveDate)
            items.append(ValueFormItem(title: NSLocalizedString("Effective From", comment: ""), value: dateString).width(.column(3)))
        }
        
        return items
    }
    
    private func aliasBlock(for organisation: Organisation) -> [FormItem] {
        let title = LargeTextHeaderFormItem(text: NSLocalizedString("Aliases", comment: ""), separatorColor: .clear)
        guard let aliases = organisation.aliases else { return [title] }
    
        return [title] + aliases.map {
            let formTitle = $0.dateCreated != nil ? NSLocalizedString("Recorded on \($0.dateCreated!)", comment: "") : NSLocalizedString("", comment: "")
            return ValueFormItem(title: formTitle, value: $0.formattedName).width(.column(3)) as FormItem
        }
    }
    
    open override var title: String? {
        return NSLocalizedString("Information", comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Organisation Found", comment: "")
    }
    
    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this organisation", comment: "")
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }
    
    open func mapSummaryDisplayable() -> EntityMapSummaryDisplayable? {
        guard let organisation = entity as? Organisation else {
            return nil
        }
        
        return OrganisationSummaryDisplayable(organisation)
    }
    
    open func latLongString() -> String? {
        guard let location = organisation?.locations?.first,
            let lat = location.latitude,
            let long = location.longitude else { return nil }
        
        return "\(lat), \(long)"
    }
    
}
