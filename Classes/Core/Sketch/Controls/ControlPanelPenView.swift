//
//  ControlPanelPenView.swift
//  MPOLKit
//
//  Created by QHMW64 on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

class ControlPanelPenView: UIView {

    let stub = UIImageView(image: AssetManager.shared.image(forKey: .penStub))
    let nib = UIImageView(image: AssetManager.shared.image(forKey: .penNib))

    init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = true

        [stub, nib].forEach { (view: UIView) in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            view.isUserInteractionEnabled = true
        }

        NSLayoutConstraint.activate([
            nib.topAnchor.constraint(equalTo: stub.topAnchor),
            nib.centerXAnchor.constraint(equalTo: stub.centerXAnchor),

            stub.leadingAnchor.constraint(equalTo: leadingAnchor),
            stub.centerXAnchor.constraint(equalTo: centerXAnchor),
            stub.topAnchor.constraint(equalTo: topAnchor, constant: -20.0)
        ])
    }

    override var intrinsicContentSize: CGSize {
        return stub.frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
