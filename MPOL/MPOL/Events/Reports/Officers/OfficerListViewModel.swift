//
//  OfficerListViewModel.swift
//  MPOL
//
//  Created by QHMW64 on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import ClientKit
import MPOLKit

public protocol EventOfficerListViewModelDelegate: class {
    func officerListDidUpdate()
}



public class EventOfficerListViewModel {

    weak var delegate: EventOfficerListViewModelDelegate?
    public let report: OfficerListReport

    var officerDisplayables: [OfficerSummaryDisplayable] = [] {
        didSet {
            delegate?.officerListDidUpdate()
        }
    }

    init(report: OfficerListReport) {
        self.report = report
        officerDisplayables = report.officers.map { OfficerSummaryDisplayable($0) }
    }

    public var title: String? {
        return "Current officers"
    }

    public func officer(at indexPath: IndexPath) -> Officer {
        return report.officers[indexPath.row]
    }

    public func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: header)

        let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconPencil)

        officerDisplayables.enumerated().forEach {
            builder += $1.summaryListFormItem()
                .title($1.title)
                .image($1.thumbnail(ofSize: .small))
                .subtitle($1.detail1)
                .accessory(CustomItemAccessory(onCreate: { () -> UIView in
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    return imageView
                }, size: image?.size ?? .zero))
                .editActions($0 == 0 ? [] : [CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.removeOfficer(at: indexPath)
                    self.delegate?.officerListDidUpdate()
                })])
        }
    }

    public var header: String? {
        let officerCount = report.officers.count
        return "\(officerCount) CURRENT OFFICER\(officerCount == 1 ? "" : "S")"
    }

    public func add(officer: Officer) {
        officerDisplayables.append(OfficerSummaryDisplayable(officer))
        report.officers.append(officer)
    }

    func removeOfficer(at indexPath: IndexPath) {
        officerDisplayables.remove(at: indexPath.row)
        report.officers.remove(at: indexPath.row)
    }
}
