//
//  PersonDescriptionViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class PersonDescriptionViewModel {

    // MARK: - Properties

    open weak var delegate: EntityDetailFormViewModelDelegate?

    open var descriptions: [PersonDescription]? {
        didSet {
            guard let descriptions = descriptions, !descriptions.isEmpty else { return }

            var map: [String: [PersonDescription]] = [:]

            for description in descriptions {
                let year = self.year(from: description.effectiveDate)
                var yearsDescriptions = map[year] ?? []
                yearsDescriptions.append(description)
                map[year] = yearsDescriptions
            }

            // Add each years descriptions to sections array in order of year
            var sections: [(String, [PersonDescription])] = []
            let years = map.keys.sorted(by: { $0.localizedCompare($1) == .orderedDescending })
            for year in years {
                if year.count == 0 {
                    sections.append(("Unknown Year", map[year]!))
                } else {
                    sections.append((year, map[year]!))
                }
            }

            self.sections = sections
        }
    }

    private var sections: [(title: String, descriptions: [PersonDescription])] = [] {
        didSet {
            delegate?.reloadData()
        }
    }

    open var title: String? {
        return NSLocalizedString("More Descriptions", comment: "")
    }

    private var yearDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "YYYY"
        return formatter
    }

    // MARK: - Methods

    open func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        for section in sections {
            builder += HeaderFormItem(text: section.title, style: .collapsible)
            for description in section.descriptions {
                builder += ValueFormItem(title: title(for: description), value: description.formatted())
            }
        }
    }

    private func year(from date: Date?) -> String {
        if let date = date {
            return yearDateFormatter.string(from: date)
        } else {
            return ""
        }
    }

    private func title(for description: PersonDescription) -> String? {
        guard let date = description.effectiveDate else { return nil }
        return DateFormatter.preferredDateStyle.string(from: date)
    }
}
