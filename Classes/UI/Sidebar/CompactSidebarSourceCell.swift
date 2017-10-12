//
//  CompactSidebarSourceCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Table view cell representing a single source in the CompactSidebarSourceViewController
open class CompactSidebarSourceCell: UITableViewCell, DefaultReusable {

    /// The source bar cell icon showing source state
    var sourceBarCell: SourceBarCell!

    /// The title label for the source
    var sourceTitle: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        sourceBarCell = SourceBarCell(frame: .zero)
        sourceBarCell.translatesAutoresizingMaskIntoConstraints = false
        sourceBarCell.axis = .horizontal
        sourceBarCell.titleLabel.isHidden = true
        contentView.addSubview(sourceBarCell)

        sourceTitle = UILabel(frame: .zero)
        sourceTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sourceTitle)

        let margin = 20 as CGFloat
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),

            sourceBarCell.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceBarCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceBarCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sourceBarCell.widthAnchor.constraint(equalToConstant: 56),
            sourceBarCell.heightAnchor.constraint(equalToConstant: 56).withPriority(.almostRequired),

            sourceTitle.leadingAnchor.constraint(equalTo: sourceBarCell.trailingAnchor),
            sourceTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sourceTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

}
