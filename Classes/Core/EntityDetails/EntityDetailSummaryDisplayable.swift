//
//  EntityDetailSummaryDisplayable.swift
//  ClientKit
//
//  Created by RUI WANG on 14/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EntityDetailSummaryDisplayable {

    var category: String? { get }

    var title: String? { get }

    var subtitle: String? { get }

    var description: String? { get }

    var additonalButtonTitle: String? { get }

    var isPlaceholder: Bool { get }

    var alertColor: UIColor? { get }

    func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)?

}

public protocol EntityDetailSummaryDecoratable {

    func decorate(with EntityDetailSummary: EntityDetailSummaryDisplayable)

}
