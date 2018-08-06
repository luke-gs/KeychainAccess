//
//  PixelWidthView.swift
//  MPOLKit
//
//  Created by QHMW64 on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class PixelWidthView: UIView {

    var selectionHandler: (() -> ())?

    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    let nibSize: NibSize

    init(nibSize: NibSize = .giant) {
        self.nibSize = nibSize

        super.init(frame: .zero)

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:))))

        [label, imageView].forEach { (view: UIView) in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.text = "\(Int(nibSize.rawValue)) px"

        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.image = nibSize.image

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8.0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
        ])
    }

    func update(with nibSize: NibSize) {
        imageView.image = nibSize.scaledImage
        label.text = "\(Int(nibSize.rawValue)) px"
    }

    @objc private func viewTapped(gesture: UITapGestureRecognizer) {
        selectionHandler?()
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
