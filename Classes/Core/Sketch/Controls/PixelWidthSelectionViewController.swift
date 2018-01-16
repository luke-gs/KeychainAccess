//
//  PixelWidthSelectionViewController.swift
//  MPOLKit
//
//  Created by QHMW64 on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class PixelWidthSelectionViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var selectionHandler: ((NibSize) -> ())?

    let pixelViews: [PixelWidthView] = [
        PixelWidthView(nibSize: .small),
        PixelWidthView(nibSize: .medium),
        PixelWidthView(nibSize: .large),
        PixelWidthView(nibSize: .giant)
    ]

    init() {
        super.init(nibName: nil, bundle: nil)

        pixelViews.forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pixelTouched(gesture:))))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func viewDidLoad() {
        let stackView = UIStackView(arrangedSubviews: pixelViews)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.frame = view.frame
        stackView.alignment = .bottom
        stackView.distribution = .fillProportionally
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(stackView)
    }

    @objc private func pixelTouched(gesture: UITapGestureRecognizer) {
        if let pixelView = gesture.view as? PixelWidthView {
            selectionHandler?(pixelView.nibSize)
        }
    }
}
