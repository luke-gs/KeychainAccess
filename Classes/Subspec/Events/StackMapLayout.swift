//
//  StackMapLayout.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class StackMapLayout: MapFormBuilderViewLayout {

    let percentage: CGFloat

    init(mapPercentage: CGFloat = 40) {
        self.percentage = mapPercentage
        super.init()
    }

    override public func viewDidLoad() {
        guard let controller = controller,
            let mapView = controller.mapView,
            let collectionView = controller.collectionView
            else { return }

        controller.view.addSubview(mapView)

        controller.mapView?.translatesAutoresizingMaskIntoConstraints = false
        controller.collectionView?.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        // Horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapView]|", options: [], metrics: nil, views: ["mapView": mapView])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView])

        // Vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView(percentage)][collectionView]|",
                                                      options: [],
                                                      metrics: ["percentage": (controller.view.frame.size.height * (percentage/100))],
                                                      views: ["collectionView": collectionView, "mapView": mapView, "view": controller.view])

        NSLayoutConstraint.activate(constraints)
    }
}
